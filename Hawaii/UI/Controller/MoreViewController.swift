import UIKit
import GoogleSignIn

class MoreViewController: BaseViewController {

    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    var userUseCase: UserUseCaseProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    
    let adminSection = 1
    
    let showUsersManagementSegue = "showUsersManagement"
    let showHolidaysManagementSegue = "showHolidayManagement"
    let showTeamsManagementSegue = "showTeamsManagement"
    let showLeaveProfilesManagementSegue = "showLeaveProfilesManagement"
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = LocalizedKeys.More.title.localized()
        tableView.register(UINib(nibName: String(describing: ProfileTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        userUseCase?.readUser(completion: { user in
            DispatchQueue.main.async {
                self.user = user
                self.tableView.reloadData()
            }
        })
    }
    
    func signOut() {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
    
        self.userUseCase?.deleteFirebaseToken { firebaseResponse in
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

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != 1 {
            return 1
        }
        return isAdmin() ? 4 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return getProfileCell(indexPath: indexPath) ?? UITableViewCell()
        } else if indexPath.section == adminSection && isAdmin() {
            switch indexPath.row {
            case 0:
                return getDefaultCell(text: LocalizedKeys.More.manageUsers.localized())
            case 1:
                return getDefaultCell(text: LocalizedKeys.More.manageTeams.localized())
            case 2:
                return getDefaultCell(text: LocalizedKeys.More.manageHolidays.localized())
            default:
                return getDefaultCell(text: LocalizedKeys.More.manageLeaveProfiles.localized())
            }
        } else {
            return getDefaultCell(text: LocalizedKeys.More.signOut.localized())
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Profile"
        } else if section == adminSection && isAdmin() {
            return "Admin section"
        } else {
            return "Additional info"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            signOut()
        } else if indexPath.section == adminSection {
            if isAdmin() {
                switch indexPath.row {
                case 0:
                    performSegue(withIdentifier: showUsersManagementSegue, sender: nil)
                case 1:
                    performSegue(withIdentifier: showTeamsManagementSegue, sender: nil)
                case 2:
                    performSegue(withIdentifier: showHolidaysManagementSegue, sender: nil)
                default:
                    performSegue(withIdentifier: showLeaveProfilesManagementSegue, sender: nil)
                }
            } else {
                signOut()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isAdmin() ? 3 : 2
    }
    
    func isAdmin() -> Bool {
        return user?.userRole ?? "" == UserRole.hrManager.rawValue
    }
    
    func getProfileCell(indexPath: IndexPath) -> ProfileTableViewCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileTableViewCell.self),
                                                       for: indexPath)
            as? ProfileTableViewCell else {
                return nil
        }
        cell.user = user
        cell.imageUrl = userDetailsUseCase?.getPictureUrl()
        return cell
    }
    
    func getDefaultCell(text: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = text
        return cell
    }
    
}
//var userDetailsUseCase: UserDetailsUseCaseProtocol?
//
//@IBOutlet weak var tableView: UITableView!
//
//
//@IBOutlet weak var emailLabel: UILabel!
//
//@IBOutlet weak var nameLabel: UILabel!
//
//@IBOutlet weak var profileImage: UIImageView!
//
//@IBOutlet weak var signOutButton: UIButton!
//
//var userUseCase: UserUseCaseProtocol?
//
//override func viewDidLoad() {
//    super.viewDidLoad()
//
//    let genericProfileImageUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTuYaHTYdunFCkaR7OwwMXMP_pwTxs_atlJRwBKekLVMl1iQVdag"
//    let imageUrl = userDetailsUseCase?.getPictureUrl() ?? genericProfileImageUrl
//
//    self.navigationItem.title = LocalizedKeys.More.title.localized()
//    signOutButton.setTitle(LocalizedKeys.More.signOut.localized(), for: .normal)
//
//    profileImage.kf.setImage(with: URL(string: imageUrl))
//    profileImage.layer.borderWidth = 1.0
//    profileImage.layer.masksToBounds = false
//    profileImage.layer.borderColor = UIColor.white.cgColor
//    profileImage.layer.cornerRadius = 120 / 2
//    profileImage.clipsToBounds = true
//
//    userUseCase?.readUser(completion: { user in
//        DispatchQueue.main.async {
//            self.nameLabel.text = user?.fullName
//            self.emailLabel.text = user?.email
//        }
//    })
//}
//
//@IBAction func onSignOutPressed(_ sender: Any) {
//    GIDSignIn.sharedInstance().signOut()
//    GIDSignIn.sharedInstance().disconnect()
//
//    self.userUseCase?.deleteFirebaseToken { firebaseResponse in
//        guard let success = firebaseResponse?.success else {
//            self.stopActivityIndicatorSpinner()
//            return
//        }
//        if !success {
//            AlertPresenter.showAlertWithAction(title: LocalizedKeys.General.errorTitle.localized(), message: firebaseResponse?.message ?? "",
//                                               viewController: self, completion: { _ in
//                                                self.stopActivityIndicatorSpinner()
//            })
//        }
//        self.removeUserDetails()
//        self.navigateToSignIn()
//    }
//
//}
//
//func removeUserDetails() {
//    guard let userDetailsUseCase = userDetailsUseCase else {
//        return
//    }
//    userDetailsUseCase.removeEmail()
//    userDetailsUseCase.removeToken()
//}
//
//func navigateToSignIn() {
//
//    let mainStoryboardTitle = "Main"
//    let sigInViewControllerTitle = "SignInViewController"
//
//    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
//        let window = appDelegate.window else {
//            return
//    }
//    let mainStoryboard: UIStoryboard = UIStoryboard(name: mainStoryboardTitle, bundle: nil)
//
//    guard let signInViewController = mainStoryboard.instantiateViewController (withIdentifier: sigInViewControllerTitle)
//        as? SignInViewController else {
//            return
//    }
//
//    window.rootViewController = signInViewController
//    window.makeKeyAndVisible()
//}
//}
