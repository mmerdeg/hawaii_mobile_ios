import UIKit
import GoogleSignIn

class SignInViewController: BaseViewController, GIDSignInUIDelegate {
    
    var userDetailsUseCase: UserDetailsUseCase?
    
    var userUseCase: UserUseCase?
    
    @IBOutlet weak var signInButton: SignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        addObservers()
    }
    
    @objc func onSignIn(_ notification: Notification) {
        startActivityIndicatorSpinner()
        
        guard let userUseCase = userUseCase else {
                return
        }
        userUseCase.getUser { response in
            
            guard let success = response?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                GIDSignIn.sharedInstance().signOut()
                GIDSignIn.sharedInstance().disconnect()
                self.handleResponseFaliure(message: response?.message)
                return
            }
            self.userUseCase?.setFirebaseToken { firebaseResponse in
                guard let firebaseResponseSuccess = firebaseResponse?.success else {
                    self.stopActivityIndicatorSpinner()
                    return
                }
                if !firebaseResponseSuccess {
                    GIDSignIn.sharedInstance().signOut()
                    GIDSignIn.sharedInstance().disconnect()
                    self.handleResponseFaliure(message: firebaseResponse?.message)
                    return
                }
                self.navigateToHome()
                self.stopActivityIndicatorSpinner()

            }
        }
    }

    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onSignIn),
                                               name: NSNotification.Name(rawValue: NotificationNames.signedIn), object: nil)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.signedIn), object: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        stopActivityIndicatorSpinner()
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true) { () -> Void in
            self.stopActivityIndicatorSpinner()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true) { () -> Void in
            self.stopActivityIndicatorSpinner()
        }
    }
    
    @IBAction func onSignInPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func navigateToHome() {
        DispatchQueue.main.async {
            let mainStoryboardTitle = "Main"
            let homeTabBarControllerTitle = String(describing: HomeTabBarController.self)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let window = appDelegate.window else {
                    return
            }
            let mainStoryboard: UIStoryboard = UIStoryboard(name: mainStoryboardTitle, bundle: nil)
            
            guard let homeTabBarController = mainStoryboard.instantiateViewController (withIdentifier: homeTabBarControllerTitle)
                as? UITabBarController else {
                    return
            }
            
            window.rootViewController = homeTabBarController
            window.makeKeyAndVisible()
        }
    }
}
