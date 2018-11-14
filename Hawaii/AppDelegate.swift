import UIKit
import GoogleSignIn
import FMDB
import Swinject
import SwinjectStoryboard
import Firebase
import UserNotifications
import NotificationBannerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var userUseCase: UserUseCaseProtocol?
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    var isFirebaseInitialized = false
    
    #if PRODUCTION
    let clientId = "91011414864-fse65f2pje2rgmobdqu8n67ld8pk6mhr.apps.googleusercontent.com"
    #else
    let clientId = "91011414864-9igmd38tpgbklpgkdpcogh9j6h7e2rt9.apps.googleusercontent.com"
    #endif
    
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        GIDSignIn.sharedInstance().clientID = clientId
        
        let container = SwinjectStoryboard.defaultContainer
        
        userUseCase = container.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
        userDetailsUseCase = container.resolve(UserDetailsUseCaseProtocol.self,
                                              name: String(describing: UserDetailsUseCaseProtocol.self))
        StyleSetup.setStyles()
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self

        if #available(iOS 11.0, *) {
            let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                    title: LocalizedKeys.General.accept.localized(),
                                                    options: UNNotificationActionOptions(rawValue: 0))
            let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                     title: LocalizedKeys.General.decline.localized(),
                                                     options: UNNotificationActionOptions(rawValue: 0))
            
            let meetingInviteCategory =
                UNNotificationCategory(identifier: "requestNotification",
                                       actions: [acceptAction, declineAction],
                                       intentIdentifiers: [],
                                       hiddenPreviewsBodyPlaceholder: "",
                                       options: .customDismissAction)

            UNUserNotificationCenter.current().setNotificationCategories([meetingInviteCategory])
        }

        if #available(iOS 10, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { granted, _ in
                if granted {
                    print("Notification Enabled Successfully")
                } else {
                    print("Some Error Occured")
                }
            }
            application.registerForRemoteNotifications()
        }
        chooseInitialView()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [ UIApplicationOpenURLOptionsKey: Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                    annotation: [:])
    }
    
    func chooseInitialView() {
                
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            guard let homeTabBarController = mainStoryboard.instantiateViewController(withIdentifier: "HomeTabBarController")
                as? UITabBarController else {
                    return
            }
            self.window?.rootViewController = homeTabBarController
        } else {
            guard let signInViewController = mainStoryboard.instantiateViewController (withIdentifier: "SignInViewController")
                                             as? SignInViewController else {
                return
            }
            self.window?.rootViewController = signInViewController
        }
        self.window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Messaging.messaging().appDidReceiveMessage(userInfo)

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }

}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
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
        case .pending:
            let banner = NotificationBanner(title: title, subtitle: body, style: .warning)
            banner.show()
        default:
            let banner = NotificationBanner(title: title, subtitle: body, style: .info)
            banner.show()
        }
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: NotificationNames.refreshData),
                                        object: nil, userInfo: nil)
        completionHandler([.badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"),
                                        object: nil, userInfo: dataDict)
        userDetailsUseCase?.setFirebaseToken(fcmToken)
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

extension SwinjectStoryboard {
    @objc class func setup() {
        
        DatabaseInitializer().initialize { databaseQueue, dispatchQueue in
            
            // Repository
            
            let userDao = UserDao(dispatchQueue: dispatchQueue, databaseQueue: databaseQueue)
            let requestRepository = RequestRepository()
            let publicHolidayRepository = PublicHolidayRepository()
            let keyChainRepository = KeyChainRepository()
            let userDetailsRepository = UserDetailsRepository(keyChainRepository: keyChainRepository)
            let userRepository = UserRepository()
            let tableDataProviderRepository = TableDataProviderRepository()
            
            // UseCase
            
            let userDetailsUseCase = UserDetailsUseCase(userDetailsRepository: userDetailsRepository)
            let userUseCase = UserUseCase(userRepository: userRepository, userDao: userDao, userDetailsUseCase: userDetailsUseCase)
            
            // Repository registration
            
            defaultContainer.register(UserDaoProtocol.self, name: String(describing: UserDaoProtocol.self)) { _ in
                userDao
            }
            defaultContainer.register(RequestRepositoryProtocol.self, name: String(describing: RequestRepositoryProtocol.self)) { _ in
                requestRepository
            }
            defaultContainer.register(PublicHolidayRepositoryProtocol.self, name: String(describing: PublicHolidayRepositoryProtocol.self)) { _ in
                publicHolidayRepository
            }
            defaultContainer.register(UserRepositoryProtocol.self, name: String(describing: UserRepositoryProtocol.self)) { _ in
                userRepository
            }
            defaultContainer.register(TableDataProviderRepository.self, name: String(describing: TableDataProviderRepositoryProtocol.self)) { _ in
                tableDataProviderRepository
            }
            defaultContainer.register(KeyChainRepositoryProtocol.self, name: String(describing: KeyChainRepositoryProtocol.self)) { _ in
                keyChainRepository
            }
            defaultContainer.register(UserDetailsRepositoryProtocol.self, name: String(describing: UserDetailsRepositoryProtocol.self)) { resolver in
                UserDetailsRepository(
                    keyChainRepository: resolver.resolve(KeyChainRepositoryProtocol.self,
                                        name: String(describing: KeyChainRepositoryProtocol.self)) ?? keyChainRepository)
            }
            
            // UseCase registration
            
            defaultContainer.register(PublicHolidayUseCaseProtocol.self, name: String(describing: PublicHolidayUseCaseProtocol.self)) { resolver in
                PublicHolidayUseCase(
                    publicHolidayRepository: resolver.resolve(PublicHolidayRepositoryProtocol.self,
                                             name: String(describing: PublicHolidayRepositoryProtocol.self)) ?? publicHolidayRepository,
                    userDetailsUseCase: resolver.resolve(UserDetailsUseCaseProtocol.self,
                                        name: String(describing: UserDetailsUseCaseProtocol.self)) ?? userDetailsUseCase)
            }
            
            defaultContainer.register(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self)) { resolver in
                UserUseCase(
                    userRepository: resolver.resolve(UserRepositoryProtocol.self,
                                     name: String(describing: UserRepositoryProtocol.self)) ?? userRepository,
                    userDao: resolver.resolve(UserDaoProtocol.self,
                             name: String(describing: UserDaoProtocol.self)) ?? userDao,
                    userDetailsUseCase: resolver.resolve(UserDetailsUseCaseProtocol.self,
                                        name: String(describing: UserDetailsUseCaseProtocol.self)) ?? userDetailsUseCase)
            }
            
            defaultContainer.register(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self)) { resolver in
                RequestUseCase(
                    entityRepository: resolver.resolve(RequestRepositoryProtocol.self,
                                      name: String(describing: RequestRepositoryProtocol.self)) ?? requestRepository,
                    userUseCase: resolver.resolve(UserUseCaseProtocol.self,
                                 name: String(describing: UserUseCaseProtocol.self)) ?? userUseCase,
                    userDetailsUseCase: resolver.resolve(UserDetailsUseCaseProtocol.self,
                                        name: String(describing: UserDetailsUseCaseProtocol.self)) ?? userDetailsUseCase)
            }
            
            defaultContainer.register(TableDataProviderUseCaseProtocol.self,
                                      name: String(describing: TableDataProviderUseCaseProtocol.self)) { resolver in
                TableDataProviderUseCase(
                    tableDataProviderRepository: resolver.resolve(TableDataProviderRepositoryProtocol.self,
                                                 name: String(describing: TableDataProviderRepositoryProtocol.self)) ?? tableDataProviderRepository)
            }
            
            defaultContainer.register(UserDetailsUseCaseProtocol.self, name: String(describing: UserDetailsUseCaseProtocol.self)) { resolver in
                UserDetailsUseCase(
                    userDetailsRepository: resolver.resolve(UserDetailsRepositoryProtocol.self,
                                           name: String(describing: UserDetailsRepositoryProtocol.self)) ?? userDetailsRepository)
            }
            
            // View Controller
            
            defaultContainer.storyboardInitCompleted(DashboardViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
                controller.publicHolidaysUseCase = resolver.resolve(PublicHolidayUseCaseProtocol.self,
                                                                    name: String(describing: PublicHolidayUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(TeamCalendarViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
                controller.publicHolidaysUseCase = resolver.resolve(PublicHolidayUseCaseProtocol.self,
                                                                    name: String(describing: PublicHolidayUseCaseProtocol.self))
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(SearchUsersBaseViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                 name: String(describing: UserDetailsUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(NewRequestViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(SummaryViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(RemainigDaysViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(HistoryViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(ApproveViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(RequestDetailsViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(RequestTableViewController.self) { resolver, controller in
                controller.tableDataProviderUseCase = resolver.resolve(TableDataProviderUseCaseProtocol.self,
                                                                       name: String(describing: TableDataProviderUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(SignInViewController.self) { resolver, controller in
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                 name: String(describing: UserDetailsUseCaseProtocol.self))
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(MoreViewController.self) { resolver, controller in
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                 name: String(describing: UserDetailsUseCaseProtocol.self))
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(SelectAbsenceViewController.self) { resolver, controller in
                controller.tableDataProviderUseCase = resolver.resolve(TableDataProviderUseCaseProtocol.self,
                                                                       name: String(describing: TableDataProviderUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(SearchRequestsViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(CustomDatePickerTableViewController.self) { resolver, controller in
                controller.publicHolidaysUseCase = resolver.resolve(PublicHolidayUseCaseProtocol.self,
                                                                    name: String(describing: PublicHolidayUseCaseProtocol.self))
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(HomeTabBarController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                 name: String(describing: UserDetailsUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(SearchUsersTableViewController.self) { resolver, controller in
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                 name: String(describing: UserDetailsUseCaseProtocol.self))
            }
        }
    }
    
}
