import UIKit
import GoogleSignIn
import Firebase
import SwinjectStoryboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
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
        signIn?.scopes = ["https://www.googleapis.com/auth/plus.login", "https://www.googleapis.com/auth/plus.me"]
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if Auth.auth().currentUser != nil {
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
        // Request Repository
        defaultContainer.register(RequestRepositoryProtocol.self, name: String(describing: RequestRepositoryProtocol.self)) { _ in
            return RequestRepository()
        }
        defaultContainer.register(RequestUseCaseProtocol.self,
                                  name: String(describing: RequestUseCaseProtocol.self)) { resolver in
            RequestUseCase(entityRepository: resolver.resolve(RequestRepositoryProtocol.self,
                                                              name: String(describing: RequestUseCaseProtocol.self)) ?? RequestRepository())
        }
        
        // Table Data Provider Repository
        defaultContainer.register(TableDataProviderRepository.self, name: String(describing: TableDataProviderRepositoryProtocol.self)) { _ in
            return TableDataProviderRepository()
        }
        defaultContainer.register(TableDataProviderUseCaseProtocol.self,
                                  name: String(describing: TableDataProviderUseCaseProtocol.self)) { resolver in
                                    TableDataProviderUseCase(tableDataProviderRepository: resolver.resolve(TableDataProviderRepositoryProtocol.self,
                                                                                      name: String(describing: TableDataProviderUseCaseProtocol.self))
                                                                                        ?? TableDataProviderRepository())
        }
        
        defaultContainer.storyboardInitCompleted(DashboardViewController.self) { resolver, controller in
            controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(HistoryViewController.self) { resolver, controller in
            controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
        }
        
        defaultContainer.storyboardInitCompleted(RequestTableViewController.self) { resolver, controller in
            controller.tableDataProviderUseCase = resolver.resolve(TableDataProviderUseCaseProtocol.self,
                                                                   name: String(describing: TableDataProviderUseCaseProtocol.self))
        }
    }
}
