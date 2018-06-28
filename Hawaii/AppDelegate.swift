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
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                    sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                    annotation: [:])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        //This can occur for certain types of temporary interruptions (such as an incoming phone call
        //or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough
        //application state information to restore your application to its current state in case it is terminated
        //later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func chooseInitialView(){
        
        let signIn = GIDSignIn.sharedInstance()
        signIn?.scopes = ["https://www.googleapis.com/auth/plus.login","https://www.googleapis.com/auth/plus.me"]
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if Auth.auth().currentUser != nil {
            guard let homeTabBarController = mainStoryboard.instantiateViewController(withIdentifier: "HomeTabBarController") as? UITabBarController else {
                return
            }
            self.window?.rootViewController = homeTabBarController
        } else {
            guard let signInViewController = mainStoryboard.instantiateViewController (withIdentifier: "SignInViewController") as? SignInViewController else {
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
        defaultContainer.register(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self)) { resolver in
            RequestUseCase(entityRepository: resolver.resolve(RequestRepositoryProtocol.self, name: String(describing: RequestUseCaseProtocol.self)) ?? RequestRepository())
        }
        
        defaultContainer.storyboardInitCompleted(DashboardViewController.self) { resolver, controller in
            controller.requestUseCase = resolver.resolve(RequestUseCaseProtocol.self, name: String(describing: RequestUseCaseProtocol.self))
        }
    }
}
