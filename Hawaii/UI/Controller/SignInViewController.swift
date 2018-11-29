import UIKit
import GoogleSignIn

class SignInViewController: BaseViewController, GIDSignInUIDelegate {
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    var userUseCase: UserUseCaseProtocol?
    
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
            guard let user = response?.item else {
                self.stopActivityIndicatorSpinner()
                return
            }
            
            self.userUseCase?.create(entity: user, completion: { _ in
                
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
                    guard let token = firebaseResponse?.item else {
                        self.stopActivityIndicatorSpinner()
                        return
                    }
                    self.userUseCase?.create(entity: token, userId: nil, completion: { _ in
                        self.navigateToHome()
                        self.stopActivityIndicatorSpinner()
                    })
                }

            })
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
            self.performSegue(withIdentifier: "homeVCSegue", sender: self)
        }
    }
}
