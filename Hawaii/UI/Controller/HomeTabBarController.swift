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

class HomeTabBarController: UITabBarController {
    
    let progressHUD = ProgressHUD(text: "Please wait")
    
    let gcmMessageIDKey = "gcm.message_id"
    
    var userUseCase: UserUseCaseProtocol?
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self
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
            // Define the custom actions.
            let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                    title: "Accept",
                                                    options: UNNotificationActionOptions(rawValue: 0))
            let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                     title: "Decline",
                                                     options: UNNotificationActionOptions(rawValue: 0))
            // Define the notification type
            if #available(iOS 11.0, *) {
                let meetingInviteCategory =
                    UNNotificationCategory(identifier: "requestNotification",
                                           actions: [acceptAction, declineAction],
                                           intentIdentifiers: [],
                                           hiddenPreviewsBodyPlaceholder: "",
                                           options: .customDismissAction)
                
                UNUserNotificationCenter.current().setNotificationCategories([meetingInviteCategory])
            } else {
                // Fallback on earlier versions
            }
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
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.sandbox)
    }

}

extension HomeTabBarController: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification.request.content.userInfo)
        guard let userInfo = notification.request.content.userInfo["aps"] as? [String: Any],
            let alert = userInfo["alert"] as? [String: Any],
            let body = alert["body"] as? String,
            let title = alert["title"] as? String,
            let requestStatus = notification.request.content.userInfo["requestStatus"] as? String,
            let reqeust = notification.request.content.userInfo["request"] as? [String: Any] else {
                return
        }
        let status = RequestStatus(rawValue: requestStatus) ?? RequestStatus.rejected
        
//        // Generate top floating entry and set some properties
//        var attributes = EKAttributes.topFloat
//        attributes.entryBackground = .gradient(gradient: .init(colors: [.red, .green], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
//        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
//        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
//        attributes.statusBar = .dark
//        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
//        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.minEdge), height: .intrinsic)
//
//        let titleLabel = EKProperty.LabelContent(text: title, style: .init(font: titleFont, color: textColor))
//        let description = EKProperty.LabelContent(text: body, style: .init(font: descFont, color: textColor))
//        let image = EKProperty.ImageContent(image: UIImage(named: imageName)!, size: CGSize(width: 35, height: 35))
//        let simpleMessage = EKSimpleMessage(image: image, title: titleLabel, description: description)
//        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
//
//        let contentView = EKNotificationMessageView(with: notificationMessage)
//        SwiftEntryKit.display(entry: contentView, using: attributes)

//        switch status {
//        case .approved:
//            let banner = NotificationBanner(title: title, subtitle: body, style: .success)
//            banner.show()
//        case .rejected:
//            let banner = NotificationBanner(title: title, subtitle: body, style: .danger)
//            banner.show()
//        default:
//            let banner = NotificationBanner(title: title, subtitle: body, style: .warning)
//            banner.show()
//        }
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: NotificationNames.refreshData),
                                        object: nil, userInfo: nil)
        completionHandler([.badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension HomeTabBarController: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"),
                                        object: nil, userInfo: dataDict)
        userDetailsUseCase?.setFirebaseToken(fcmToken)
        userUseCase?.setFirebaseToken { _ in
            
        }
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
