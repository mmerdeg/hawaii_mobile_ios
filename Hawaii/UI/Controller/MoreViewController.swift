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
    let profileManagementSegue = "profileManagement"
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = LocalizedKeys.More.title.localized()
        tableView.register(UINib(nibName: String(describing: ProfileTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ThemeTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ThemeTableViewCell.self))
        tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        Thread.printCurrent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
        self.userUseCase?.deleteFirebaseToken(pushToken: nil) { firebaseResponse in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileManagementSegue {
            guard let controller = segue.destination as? ProfileViewController else {
                return
            }
            controller.user = user
        }
    }
}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != adminSection {
            return section == 0 ? 1 : 3
        }
        return isAdmin() ? 4 : 2
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
            switch indexPath.row {
            case 0:
                return getThemeCell(indexPath: indexPath) ?? UITableViewCell()
            case 1:
                return getDefaultCell(text: LocalizedKeys.More.manageDevices.localized())
            default:
                return getDefaultCell(text: LocalizedKeys.More.signOut.localized())
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Profile"
        } else if section == adminSection && isAdmin() {
            return "Admin section"
        } else {
            return "Additional options"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if indexPath.row == 1 {
                self.performSegue(withIdentifier: profileManagementSegue, sender: nil)
            } else {
                signOut()
            }
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
                if indexPath.row == 1 {
                    self.performSegue(withIdentifier: profileManagementSegue, sender: nil)
                } else {
                    signOut()
                }
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
    
    func getThemeCell(indexPath: IndexPath) -> ThemeTableViewCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ThemeTableViewCell.self),
                                                       for: indexPath)
            as? ThemeTableViewCell else {
                return nil
        }
        cell.userDetailsUseCase = userDetailsUseCase
        cell.themeSwitch.isOn = userDetailsUseCase?.isLightThemeSelected() ?? false
        return cell
    }
    
    func getDefaultCell(text: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = text
        return cell
    }
    
}

extension Thread {
    class func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}
