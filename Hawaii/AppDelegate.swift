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
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 1, green: 0.2355545163, blue: 0.1967591643, alpha: 1)
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
        defaultContainer.register(RequestRepositoryProtocol.self, name: String(describing: RequestRepositoryProtocol.self)) { _ in
            return RequestRepository()
        }
        defaultContainer.register(RequestUseCaseProtocol.self,
                                  name: String(describing: RequestUseCaseProtocol.self)) { resolver in
            RequestUseCase(entityRepository: resolver.resolve(RequestRepositoryProtocol.self,
                                                              name: String(describing: RequestUseCaseProtocol.self)) ?? RequestRepository())
        }
        
        defaultContainer.storyboardInitCompleted(DashboardViewController.self) { resolver, controller in
            controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
        }
    }
}
