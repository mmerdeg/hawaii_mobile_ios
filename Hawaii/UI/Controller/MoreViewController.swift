import UIKit
import GoogleSignIn

class MoreViewController: BaseViewController {

    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    var userUseCase: UserUseCaseProtocol?
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let genericProfileImageUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTuYaHTYdunFCkaR7OwwMXMP_pwTxs_atlJRwBKekLVMl1iQVdag"
        let imageUrl = userDetailsUseCase?.getPictureUrl() ?? genericProfileImageUrl
        
        self.navigationItem.title = LocalizedKeys.More.title.localized()
        signOutButton.setTitle(LocalizedKeys.More.signOut.localized(), for: .normal)
        
        profileImage.kf.setImage(with: URL(string: imageUrl))
        profileImage.layer.borderWidth = 1.0
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.cornerRadius = 120 / 2
        profileImage.clipsToBounds = true
        
        userUseCase?.readUser(completion: { user in
            DispatchQueue.main.async {
                self.nameLabel.text = user?.fullName
                self.emailLabel.text = user?.email
            }
        })
    }
    
    @IBAction func onSignOutPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        
        self.userUseCase?.setEmptyFirebaseToken { firebaseResponse in
            guard let success = firebaseResponse?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                AlertPresenter.showAlertWithAction(title: LocalizedKeys.General.errorTitle.localized(), message: firebaseResponse?.message ?? "",
                                                viewController: self, completion: { _ in
                    self.stopActivityIndicatorSpinner()
                })
            }
            self.removeUserDetails()
            self.navigateToSignIn()
        }
        
    }
    
    func removeUserDetails() {
        guard let userDetailsUseCase = userDetailsUseCase else {
            return
        }
        userDetailsUseCase.removeEmail()
        userDetailsUseCase.removeToken()
    }
    
    func navigateToSignIn() {
        
        let mainStoryboardTitle = "Main"
        let sigInViewControllerTitle = "SignInViewController"
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else {
                return
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: mainStoryboardTitle, bundle: nil)
        
        guard let signInViewController = mainStoryboard.instantiateViewController (withIdentifier: sigInViewControllerTitle)
            as? SignInViewController else {
                return
        }
        
        window.rootViewController = signInViewController
        window.makeKeyAndVisible()
    }
}
