import UIKit
import Firebase
import UserNotifications
import NotificationBannerSwift

class HomeTabBarController: UITabBarController {
    
    let progressHUD = ProgressHUD(text: LocalizedKeys.General.wait.localized())
    
    let gcmMessageIDKey = "gcm.message_id"
    
    @IBOutlet weak var homeTabBar: UITabBar!
    
    var userUseCase: UserUseCaseProtocol?
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Messaging.messaging().delegate = self
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
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
        homeTabBar.items?[0].title = LocalizedKeys.Dashboard.title.localized()
        homeTabBar.items?[1].title = LocalizedKeys.History.title.localized()
        homeTabBar.items?[2].title = LocalizedKeys.Team.tabItemTitle.localized()
        homeTabBar.items?[3].title = LocalizedKeys.Approval.tabItemTitle.localized()
        homeTabBar.items?[4].title = LocalizedKeys.More.title.localized()
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
            let banner = NotificationBanner(title: title, subtitle: body, style: .warning)
            banner.show()
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
        NotificationCenter.default.post(name: Notification.Name("FCMToken"),
                                        object: nil, userInfo: dataDict)
        userDetailsUseCase?.setFirebaseToken(fcmToken)
        userUseCase?.setFirebaseToken { _ in
            
        }
    }
}
