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
    
    var userUseCase: UserUseCase?
    
    var userDetailsUseCase: UserDetailsUseCase?
    
    var signInUseCase: SignInUseCase?
    
    var isFirebaseInitialized = false
    
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let container = SwinjectStoryboard.defaultContainer
        
        userUseCase = container.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
        userDetailsUseCase = container.resolve(UserDetailsUseCase.self,
                                              name: String(describing: UserDetailsUseCase.self))
        signInUseCase = container.resolve(SignInUseCase.self, name: String(describing: SignInUseCase.self))
        
        StyleSetup.setStyles()
        FirebaseApp.configure()
        signInUseCase?.initGoogleSignIn()
        
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
        
        if let userDetailsUseCase = userDetailsUseCase {
            UIColor.initWithColorScheme(colorScheme: userDetailsUseCase.isLightThemeSelected() ? .light : .dark)
        }
        
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
            
            // Mandatory registration order section
            
            let keyChainRepository = KeyChainRepository()
            let userDetailsRepository = UserDetailsRepositoryImplementation(keyChainRepository: keyChainRepository)
          
            let userDetailsUseCase = UserDetailsUseCaseImplementation(userDetailsRepository: userDetailsRepository)
            
            let refreshTokenGroup = DispatchGroup()
            let signInUseCase = SignInUseCaseImplementation(userDetailsUseCase: userDetailsUseCase, refreshTokenGroup: refreshTokenGroup)
            
            defaultContainer.register(KeyChainRepositoryProtocol.self, name: String(describing: KeyChainRepositoryProtocol.self)) { _ in
                keyChainRepository
            }
            
            defaultContainer.register(UserDetailsRepository.self, name: String(describing: UserDetailsRepository.self)) { resolver in
                UserDetailsRepositoryImplementation(
                    keyChainRepository: resolver.resolve(KeyChainRepositoryProtocol.self,
                                                         name: String(describing: KeyChainRepositoryProtocol.self)) ?? keyChainRepository)
            }
            
            defaultContainer.register(UserDetailsUseCase.self, name: String(describing: UserDetailsUseCase.self)) { resolver in
                UserDetailsUseCaseImplementation(
                    userDetailsRepository: resolver.resolve(UserDetailsRepository.self,
                                                            name: String(describing: UserDetailsRepository.self)) ?? userDetailsRepository)
            }
            
            defaultContainer.register(SignInUseCase.self, name: String(describing: SignInUseCase.self)) { resolver in
                SignInUseCaseImplementation(
                    userDetailsUseCase: resolver.resolve(UserDetailsUseCase.self,
                                                         name: String(describing: UserDetailsUseCase.self)) ?? userDetailsUseCase,
                    refreshTokenGroup: refreshTokenGroup)
            }
            
            defaultContainer.register(InterceptorProtocol.self, name: String(describing: InterceptorProtocol.self)) { resolver in
                Interceptor(
                    signInUseCase: resolver.resolve(SignInUseCase.self,
                                                    name: String(describing: SignInUseCase.self)) ?? signInUseCase)
            }
            
            // Repository
            
            let userDao = UserDaoImplementation(dispatchQueue: dispatchQueue, databaseQueue: databaseQueue)
            let requestRepository = RequestRepositoryImplementation()
            let publicHolidayRepository = PublicHolidayRepositoryImplementation()
            let userRepository = UserRepositoryImplementation()
            let tableDataProviderRepository = TableDataProviderRepositoryImplementation()
            let teamRepository = TeamRepositoryImplementation()
            let leaveProfileRepository = LeaveProfileRepositoryImplementation()
            
            // UseCase
            
            let userUseCase = UserUseCaseImplementation(userRepository: userRepository, userDao: userDao, userDetailsUseCase: userDetailsUseCase)
            
            // Repository registration
            
            defaultContainer.register(UserDao.self, name: String(describing: UserDao.self)) { _ in
                userDao
            }
            
            defaultContainer.register(TeamRepository.self, name: String(describing: TeamRepository.self)) { _ in
                teamRepository
            }
            
            defaultContainer.register(LeaveProfileRepository.self, name: String(describing: LeaveProfileRepository.self)) { _ in
                leaveProfileRepository
            }
            
            defaultContainer.register(RequestRepository.self, name: String(describing: RequestRepository.self)) { _ in
                requestRepository
            }
            
            defaultContainer.register(PublicHolidayRepository.self, name: String(describing: PublicHolidayRepository.self)) { _ in
                publicHolidayRepository
            }
            
            defaultContainer.register(UserRepository.self, name: String(describing: UserRepository.self)) { _ in
                userRepository
            }
            
            defaultContainer.register(TableDataProviderRepositoryImplementation.self, name: String(describing: TableDataProviderRepository.self)) { _ in
                tableDataProviderRepository
            }
            
            // UseCase registration
            
            defaultContainer.register(PublicHolidayUseCase.self, name: String(describing: PublicHolidayUseCase.self)) { resolver in
                PublicHolidayUseCaseImplementation(
                    publicHolidayRepository: resolver.resolve(PublicHolidayRepository.self,
                                             name: String(describing: PublicHolidayRepository.self)) ?? publicHolidayRepository)
            }
            
            defaultContainer.register(UserUseCase.self, name: String(describing: UserUseCase.self)) { resolver in
                UserUseCaseImplementation(
                    userRepository: resolver.resolve(UserRepository.self,
                                     name: String(describing: UserRepository.self)) ?? userRepository,
                    userDao: resolver.resolve(UserDao.self,
                             name: String(describing: UserDao.self)) ?? userDao,
                    userDetailsUseCase: resolver.resolve(UserDetailsUseCase.self,
                                        name: String(describing: UserDetailsUseCase.self)) ?? userDetailsUseCase)
            }
            
            defaultContainer.register(RequestUseCase.self, name: String(describing: RequestUseCase.self)) { resolver in
                RequestUseCaseImplementation(
                    entityRepository: resolver.resolve(RequestRepository.self,
                                      name: String(describing: RequestRepository.self)) ?? requestRepository,
                    userUseCase: resolver.resolve(UserUseCase.self,
                                 name: String(describing: UserUseCase.self)) ?? userUseCase)
            }
            
            defaultContainer.register(TableDataProviderUseCase.self,
                                      name: String(describing: TableDataProviderUseCase.self)) { resolver in
                TableDataProviderUseCaseImplementation(
                    tableDataProviderRepository: resolver.resolve(TableDataProviderRepository.self,
                                                 name: String(describing: TableDataProviderRepository.self)) ?? tableDataProviderRepository)
            }
            
            defaultContainer.register(TeamUseCase.self, name: String(describing: TeamUseCase.self)) { resolver in
                TeamUseCaseImplementation(
                    teamRepository: resolver.resolve(TeamRepository.self,
                                    name: String(describing: TeamRepository.self)) ?? teamRepository)
            }
            
            defaultContainer.register(LeaveProfileUseCase.self, name: String(describing: LeaveProfileUseCase.self)) { resolver in
                LeaveProfileUseCaseImplementation(
                    leaveProfileRepository: resolver.resolve(LeaveProfileRepository.self,
                                            name: String(describing: LeaveProfileRepository.self)) ?? leaveProfileRepository)
            }
            
            // View Controller
            
            defaultContainer.storyboardInitCompleted(DashboardViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCase.self, name: String(describing: RequestUseCase.self))
                controller.publicHolidaysUseCase = resolver.resolve(PublicHolidayUseCase.self,
                                                                    name: String(describing: PublicHolidayUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(TeamCalendarViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCase.self, name: String(describing: RequestUseCase.self))
                controller.publicHolidaysUseCase = resolver.resolve(PublicHolidayUseCase.self,
                                                                    name: String(describing: PublicHolidayUseCase.self))
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(SearchUsersBaseViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCase.self,
                                                                 name: String(describing: UserDetailsUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(NewRequestViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
                controller.requestUseCase = resolver.resolve(RequestUseCase.self, name: String(describing: RequestUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(SummaryViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCase.self, name: String(describing: RequestUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(RemainigDaysViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(HistoryViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCase.self, name: String(describing: RequestUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(ApproveViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCase.self, name: String(describing: RequestUseCase.self))
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCase.self,
                                                                 name: String(describing: UserDetailsUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(RequestDetailsViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCase.self, name: String(describing: RequestUseCase.self))
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(RequestTableViewController.self) { resolver, controller in
                controller.tableDataProviderUseCase = resolver.resolve(TableDataProviderUseCase.self,
                                                                       name: String(describing: TableDataProviderUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(SignInViewController.self) { resolver, controller in
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCase.self,
                                                                 name: String(describing: UserDetailsUseCase.self))
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(MoreViewController.self) { resolver, controller in
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCase.self,
                                                                 name: String(describing: UserDetailsUseCase.self))
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(SelectAbsenceViewController.self) { resolver, controller in
                controller.tableDataProviderUseCase = resolver.resolve(TableDataProviderUseCase.self,
                                                                       name: String(describing: TableDataProviderUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(SearchRequestsViewController.self) { resolver, controller in
                controller.requestUseCase = resolver.resolve(RequestUseCase.self, name: String(describing: RequestUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(CustomDatePickerTableViewController.self) { resolver, controller in
                controller.publicHolidaysUseCase = resolver.resolve(PublicHolidayUseCase.self,
                                                                    name: String(describing: PublicHolidayUseCase.self))
                controller.requestUseCase = resolver.resolve(RequestUseCase.self, name: String(describing: RequestUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(HomeTabBarController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCase.self,
                                                                 name: String(describing: UserDetailsUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(SearchUsersTableViewController.self) { resolver, controller in
                controller.userDetailsUseCase = resolver.resolve(UserDetailsUseCase.self,
                                                                 name: String(describing: UserDetailsUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(UsersManagementViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
                controller.teamUseCase = resolver.resolve(TeamUseCase.self,
                                                          name: String(describing: TeamUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(TeamsManagementViewController.self) { resolver, controller in
                controller.teamUseCase = resolver.resolve(TeamUseCase.self,
                                                                    name: String(describing: TeamUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(PublicHolidaysManagementViewController.self) { resolver, controller in
                controller.publicHolidayUseCase = resolver.resolve(PublicHolidayUseCase.self,
                                                                   name: String(describing: PublicHolidayUseCase.self))
            }
            defaultContainer.storyboardInitCompleted(UserManagementViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
                controller.teamUseCase = resolver.resolve(TeamUseCase.self,
                                                          name: String(describing: TeamUseCase.self))
                controller.leaveProfileUseCase = resolver.resolve(LeaveProfileUseCase.self,
                                                                  name: String(describing: LeaveProfileUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(TeamManagementViewController.self) { resolver, controller in
                controller.teamUseCase = resolver.resolve(TeamUseCase.self,
                                                          name: String(describing: TeamUseCase.self))
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(LeaveProfileManagementViewController.self) { resolver, controller in
                controller.leaveProfileUseCase = resolver.resolve(LeaveProfileUseCase.self,
                                                                  name: String(describing: LeaveProfileUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(LeaveProfilesManagementViewController.self) { resolver, controller in
                controller.leaveProfileUseCase = resolver.resolve(LeaveProfileUseCase.self,
                                                                  name: String(describing: LeaveProfileUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(PublicHolidayManagementViewController.self) { resolver, controller in
                controller.publicHolidayUseCase = resolver.resolve(PublicHolidayUseCase.self,
                                                                   name: String(describing: PublicHolidayUseCase.self))
            }
            
            defaultContainer.storyboardInitCompleted(ProfileViewController.self) { resolver, controller in
                controller.userUseCase = resolver.resolve(UserUseCase.self, name: String(describing: UserUseCase.self))
            }
            
        }
        
    }
    
}
