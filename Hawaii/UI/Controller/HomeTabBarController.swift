//
//  HomeTabBarController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 10/1/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import NotificationBannerSwift

class HomeTabBarController: UITabBarController {
    
    let progressHUD = ProgressHUD(text: "Please wait")
    
    let gcmMessageIDKey = "gcm.message_id"
    
    var userUseCase: UserUseCaseProtocol?
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        Messaging.messaging().delegate = self
        FirebaseApp.configure()
        requestNotifications()
        userUseCase?.readUser(completion: { user in
            if user?.userRole ?? "" != UserRole.hrMenager.rawValue {
                let indexToRemove = 3
                if self.viewControllers?.count ?? 0 == 5 {
                    DispatchQueue.main.async {
                        self.viewControllers?.remove(at: indexToRemove)
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /**
     Show spinner.
     */
    func startActivityIndicatorSpinner() {
        DispatchQueue.main.async {
            self.progressHUD.show()
        }
    }
    
    /**
     Hide spinner.
     */
    func stopActivityIndicatorSpinner() {
        DispatchQueue.main.async {
            self.progressHUD.hide()
        }
    }
    
    func requestNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in
                
            })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }

}



extension HomeTabBarController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let userInfo = notification.request.content.userInfo["aps"] as? [String: Any],
              let alert = userInfo["alert"] as? [String: Any],
              let body = alert["body"] as? String,
              let title = alert["title"] as? String,
              let requestStatus = notification.request.content.userInfo["requestStatus"] as? String else {
                return
        }
        let status = RequestStatus(rawValue: requestStatus) ?? RequestStatus.rejected
        
        switch status {
        case .approved:
            let banner = NotificationBanner(title: title, subtitle: body, style: .success)
            banner.show()
        case .rejected:
            let banner = NotificationBanner(title: title, subtitle: body, style: .danger)
            banner.show()
        default:
            print("")
        }
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: NotificationNames.refreshData),
                                        object: nil, userInfo: nil)
        completionHandler([.badge, .sound])
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
}

extension HomeTabBarController: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        userDetailsUseCase?.setFirebaseToken(fcmToken)
        userUseCase?.setFirebaseToken { _ in
            
        }
    }
}
