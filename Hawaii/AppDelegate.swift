import UIKit
import GoogleSignIn
import FMDB
import Swinject
import SwinjectStoryboard
import Firebase
import UserNotifications
import NotificationBannerSwift

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
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().delegate = self
        
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
        Messaging.messaging().apnsToken = deviceToken
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
            let teamRepository = TeamRepository()
            let leaveProfileRepository = LeaveProfileRepository()
            // UseCase
            
            let userDetailsUseCase = UserDetailsUseCase(userDetailsRepository: userDetailsRepository)
            let userUseCase = UserUseCase(userRepository: userRepository, userDao: userDao, userDetailsUseCase: userDetailsUseCase)
            
            // Repository registration
            
            defaultContainer.register(UserDaoProtocol.self, name: String(describing: UserDaoProtocol.self)) { _ in
                userDao
            }
            
            defaultContainer.register(TeamRepositoryProtocol.self, name: String(describing: TeamRepositoryProtocol.self)) { _ in
                teamRepository
            }
            
            defaultContainer.register(LeaveProfileRepositoryProtocol.self, name: String(describing: LeaveProfileRepositoryProtocol.self)) { _ in
                leaveProfileRepository
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
                                             name: String(describing: PublicHolidayRepositoryProtocol.self)) ?? publicHolidayRepository)
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
                                 name: String(describing: UserUseCaseProtocol.self)) ?? userUseCase)
            }
            
            defaultContainer.register(TableDataProviderUseCaseProtocol.self,
                                      name: String(describing: TableDataProviderUseCaseProtocol.self)) { resolver in
                TableDataProviderUseCase(
                    tableDataProviderRepository: resolver.resolve(TableDataProviderRepositoryProtocol.self,
                                                                  name: String(describing: TableDataProviderRepositoryProtocol.self))
                                                                  ?? tableDataProviderRepository)
            }
            
            defaultContainer.register(UserDetailsUseCaseProtocol.self, name: String(describing: UserDetailsUseCaseProtocol.self)) { resolver in
                UserDetailsUseCase(
                    userDetailsRepository: resolver.resolve(UserDetailsRepositoryProtocol.self,
                                           name: String(describing: UserDetailsRepositoryProtocol.self)) ?? userDetailsRepository)
            }
            
            defaultContainer.register(TeamUseCaseProtocol.self,
                                      name: String(describing: TeamUseCaseProtocol.self)) { resolver in
                                        TeamUseCase(teamRepository: resolver.resolve(TeamRepositoryProtocol.self,
                                                                                     name: String(describing: TeamRepositoryProtocol.self))
                                                                                     ?? teamRepository)
            }
            
            defaultContainer.register(LeaveProfileUseCaseProtocol.self,
                                      name: String(describing: LeaveProfileUseCaseProtocol.self)) { resolver in
                                        LeaveProfileUseCase(leaveProfileRepository: resolver.resolve(LeaveProfileRepositoryProtocol.self,
                                                                                                            name: String(describing: LeaveProfileRepositoryProtocol.self))
                                                ?? leaveProfileRepository)
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
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCaseProtocol.self,
                                                                 name: String(describing: UserDetailsUseCaseProtocol.self))
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
            
            defaultContainer.storyboardInitCompleted(UsersManagementViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
                controller.teamUseCase = resolver.resolve(TeamUseCaseProtocol.self,
                                                          name: String(describing: TeamUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(TeamsManagementViewController.self) { resolver, controller in
                controller.teamUseCase = resolver.resolve(TeamUseCaseProtocol.self,
                                                                    name: String(describing: TeamUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(PublicHolidaysManagementViewController.self) { resolver, controller in
                controller.publicHolidayUseCase = resolver.resolve(PublicHolidayUseCaseProtocol.self,
                                                                   name: String(describing: PublicHolidayUseCaseProtocol.self))
            }
            defaultContainer.storyboardInitCompleted(UserManagementViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
                controller.teamUseCase = resolver.resolve(TeamUseCaseProtocol.self,
                                                          name: String(describing: TeamUseCaseProtocol.self))
                controller.leaveProfileUseCase = resolver.resolve(LeaveProfileUseCaseProtocol.self,
                                                                  name: String(describing: LeaveProfileUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(TeamManagementViewController.self) { resolver, controller in
                controller.teamUseCase = resolver.resolve(TeamUseCaseProtocol.self,
                                                          name: String(describing: TeamUseCaseProtocol.self))
                controller.userUseCase = resolver.resolve(UserUseCaseProtocol.self, name: String(describing: UserUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(LeaveProfileManagementViewController.self) { resolver, controller in
                controller.leaveProfileUseCase = resolver.resolve(LeaveProfileUseCaseProtocol.self,
                                                                  name: String(describing: LeaveProfileUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(LeaveProfilesManagementViewController.self) { resolver, controller in
                controller.leaveProfileUseCase = resolver.resolve(LeaveProfileUseCaseProtocol.self,
                                                                  name: String(describing: LeaveProfileUseCaseProtocol.self))
            }
            
            defaultContainer.storyboardInitCompleted(PublicHolidayManagementViewController.self) { resolver, controller in
                controller.publicHolidayUseCase = resolver.resolve(PublicHolidayUseCaseProtocol.self,
                                                                   name: String(describing: PublicHolidayUseCaseProtocol.self))
            }
            
        }
        
    }
    
}
