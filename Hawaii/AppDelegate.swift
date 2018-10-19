import UIKit
import GoogleSignIn
import FMDB
import Swinject
import SwinjectStoryboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().clientID = "91011414864-e6j3me9ij99sk8gu6ikgad55qcdtobpl.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().serverClientID = "91011414864-oscjl6qmm6qds4kuvvh1j991rgvker3h.apps.googleusercontent.com"
        
        chooseInitialView()
        StyleSetup.setStyles()
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
