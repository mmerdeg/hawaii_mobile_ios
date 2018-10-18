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
    
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().clientID = "91011414864-e6j3me9ij99sk8gu6ikgad55qcdtobpl.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().serverClientID = "91011414864-oscjl6qmm6qds4kuvvh1j991rgvker3h.apps.googleusercontent.com"
        
        chooseInitialView()
        StyleSetup.setStyles()
        FirebaseApp.configure()
        
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in
            })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]

        Messaging.messaging().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [ UIApplicationOpenURLOptionsKey: Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                    sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                    annotation: [:])
    }
    
    func chooseInitialView() {
        
        let signIn = GIDSignIn.sharedInstance()
        signIn?.scopes = ["https://www.googleapis.com/auth/plus.login",
                          "https://www.googleapis.com/auth/plus.me",
                          "https://www.googleapis.com/auth/userinfo.email",
                          "https://www.googleapis.com/auth/userinfo.profile",
                          "https://www.googleapis.com/auth/calendar"]
        
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

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let userInfo = notification.request.content.userInfo as? [String: Any] else {
            return
        }
        let banner = NotificationBanner(title: "asdasdasd", subtitle: "sadasdasdsadsad", style: .success)
        banner.show()
        completionHandler([.badge, .sound])
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
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
       // print(userInfo)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: [.prettyPrinted]) else {
            return
        }
        let jsonString = String(data: jsonData, encoding: .utf8)
        print(jsonString)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
}

extension SwinjectStoryboard {
    @objc class func setup() {
        
        DatabaseInitializer().initialize { databaseQueue, dispatchQueue in
            
            defaultContainer.register(UserDaoProtocol.self, name: String(describing: UserDaoProtocol.self)) { _ in
                UserDao(dispatchQueue: dispatchQueue, databaseQueue: databaseQueue)
            }
            
            // Request Repository
            defaultContainer.register(RequestRepositoryProtocol.self, name: String(describing: RequestRepositoryProtocol.self)) { resolver in
                RequestRepository(userDetailsUseCase: resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                       name: String(describing: UserDetailsUseCaseProtocol.self))
                    ?? UserDetailsUseCase(userDetailsRepository: UserDetailsRepository(keyChainRepository: KeyChainRepository())))
            }
            
            defaultContainer.register(PublicHolidayRepositoryProtocol.self,
                                      name: String(describing: PublicHolidayRepositoryProtocol.self)) { resolver in
                let holidayRepository = PublicHolidayRepository()
                holidayRepository.userDetailsUseCase = resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                        name: String(describing: UserDetailsUseCaseProtocol.self))
                    ?? UserDetailsUseCase(userDetailsRepository: UserDetailsRepository(keyChainRepository: KeyChainRepository()))
                return holidayRepository
            }
            
            defaultContainer.register(PublicHolidayUseCaseProtocol.self, name: String(describing: PublicHolidayUseCaseProtocol.self)) { resolver in
                PublicHolidayUseCase(publicHolidayRepository: resolver.resolve(PublicHolidayRepositoryProtocol.self,
                                                                    name: String(describing: PublicHolidayRepositoryProtocol.self))
                    ?? PublicHolidayRepository())
            }
            
            // Request Repository
            defaultContainer.register(UserRepositoryProtocol.self, name: String(describing: UserRepositoryProtocol.self)) { resolver in
                let userRepository = UserRepository()
                userRepository.userDetailsUseCase = resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                     name: String(describing: UserDetailsUseCaseProtocol.self))
                                                                     ?? UserDetailsUseCase(userDetailsRepository:
                                                                        UserDetailsRepository(keyChainRepository: KeyChainRepository()))
                return userRepository
            }
            
            defaultContainer.register(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self)) { resolver in
                UserUseCase(userRepository: resolver.resolve(UserRepositoryProtocol.self,
                                                                    name: String(describing: UserRepositoryProtocol.self))
                    ?? UserRepository(), userDao: resolver.resolve(UserDaoProtocol.self,
                                                                   name: String(describing: UserDaoProtocol.self)) ??
                                                                   UserDao(dispatchQueue: dispatchQueue,
                                                                           databaseQueue: databaseQueue))
            }
            
            defaultContainer.register(RequestUseCaseProtocol.self,
                                      name: String(describing: RequestUseCaseProtocol.self)) { resolver in
                RequestUseCase(entityRepository: resolver.resolve(RequestRepositoryProtocol.self,
                                                                  name: String(describing: RequestRepositoryProtocol.self)) ??
                                                                    RequestRepository(userDetailsUseCase: UserDetailsUseCase(userDetailsRepository:
                                                                    UserDetailsRepository(keyChainRepository: KeyChainRepository()))),
                               userUseCase: resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
                                            ?? UserUseCase(userRepository: resolver.resolve(UserRepositoryProtocol.self,
                                                                                            name: String(describing: UserRepositoryProtocol.self))
                                                ?? UserRepository(), userDao: resolver.resolve(UserDaoProtocol.self,
                                                                               name: String(describing: UserDaoProtocol.self))
                                                    ?? UserDao(dispatchQueue: dispatchQueue,
                                                               databaseQueue: databaseQueue)))
            }
            
            // Table Data Provider Repository
            defaultContainer.register(TableDataProviderRepository.self, name: String(describing: TableDataProviderRepositoryProtocol.self)) { _ in
                TableDataProviderRepository()
            }
            defaultContainer.register(TableDataProviderUseCaseProtocol.self,
                                      name: String(describing: TableDataProviderUseCaseProtocol.self)) { resolver in
                TableDataProviderUseCase(tableDataProviderRepository: resolver.resolve(TableDataProviderRepositoryProtocol.self,
                                         name: String(describing: TableDataProviderRepositoryProtocol.self))
                                               ?? TableDataProviderRepository())
            }
            
            //Key Chain Repository
            defaultContainer.register(KeyChainRepositoryProtocol.self, name: String(describing: KeyChainRepositoryProtocol.self)) { _ in
                KeyChainRepository()
            }
            
            // User Details Repository
            defaultContainer.register(UserDetailsRepositoryProtocol.self, name: String(describing: UserDetailsRepositoryProtocol.self)) { resolver in
                UserDetailsRepository(keyChainRepository: KeyChainRepository())
//                UserDetailsRepository(keyChainRepository: resolver.resolve(KeyChainRepositoryProtocol.self, name: String(describing: KeyChainRepositoryProtocol.self)))
            }
            
            defaultContainer.register(UserDetailsUseCaseProtocol.self,
                                      name: String(describing: UserDetailsUseCaseProtocol.self)) { resolver in
                                        UserDetailsUseCase(userDetailsRepository: resolver.resolve(UserDetailsRepositoryProtocol.self,
                                                                                name: String(describing: UserDetailsRepositoryProtocol.self))
                                            ?? UserDetailsRepository(keyChainRepository: KeyChainRepository()))
            }
            
            // View Controllers
            
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
            
            defaultContainer.storyboardInitCompleted(LeaveRequestViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(SummaryViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(SickRequestViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
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
            }
            
            defaultContainer.storyboardInitCompleted(BonusRequestViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(HomeTabBarController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(SearchUsersTableViewController.self) { resolver, controller in
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                 name: String(describing: UserDetailsUseCaseProtocol.self))
            }
            
        }
    }
    
}
