import UIKit
import GoogleSignIn

class SignInViewController: BaseViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var signInApi: SignInApiProtocol?
    var label = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeGoogleSignIn()
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("User signed into google")
        guard let accessToken = user.authentication.accessToken else {
            return
        }
        guard let user = user.authentication else {
            return
        }
        print(accessToken)
        
        guard let signInApi = signInApi else {
            return
        }
        
        signInApi.signIn(accessToken: accessToken) { didSucceed in
            if didSucceed {
                print("User Logged In")
                self.navigateToHome()
            }
        }

    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        //Perform if user gets disconnected
      
        GIDSignIn.sharedInstance().signOut()
        print("User signed into google")
        
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true) { () -> Void in
        }
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true) { () -> Void in
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
