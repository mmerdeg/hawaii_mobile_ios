import UIKit
import GoogleSignIn

class SignInViewController: BaseViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    var userUseCase: UserUseCaseProtocol?
    
    @IBOutlet weak var signInButton: SignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeGoogleSignIn()
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let accessToken = user.authentication.accessToken,
            let idToken = user.authentication.idToken,
            let userUseCase = userUseCase else {
                return
        }
        
        userDetailsUseCase?.setToken(token: idToken)
        userDetailsUseCase?.setEmail(user.profile.email)
        
        userDetailsUseCase?.setToken(token: idToken)
        
        let dimension = round(100 * UIScreen.main.scale)
        if let picture = user.profile.imageURL(withDimension: UInt(dimension)) {
            userDetailsUseCase?.setPictureUrl(picture.absoluteString)
        }
        startActivityIndicatorSpinner()
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
            self.userUseCase?.createUser(entity: user, completion: { _ in
                
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
                    self.stopActivityIndicatorSpinner()
                    self.navigateToHome()
                }
                
            })
        }
        
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
    
    func initializeGoogleSignIn() {
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    func navigateToHome() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "homeVCSegue", sender: self)
        }
    }
    
}
