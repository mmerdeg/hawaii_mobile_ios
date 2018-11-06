import UIKit
import Firebase
import UserNotifications
import NotificationBannerSwift

class HomeTabBarController: UITabBarController {
    
    let progressHUD = ProgressHud(text: LocalizedKeys.General.wait.localized())
    
    let gcmMessageIDKey = "gcm.message_id"
    
    @IBOutlet weak var homeTabBar: UITabBar!
    
    var userUseCase: UserUseCaseProtocol?
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userUseCase?.readUser(completion: { user in
            if user?.userRole ?? "" != UserRole.hrMenager.rawValue && self.viewControllers?.count ?? 0 == 5 {
                DispatchQueue.main.async {
                    let indexToRemove = 3
                    self.viewControllers?.remove(at: indexToRemove)
                }
            }
        })
        
        homeTabBar.items?[0].title = LocalizedKeys.Dashboard.title.localized()
        homeTabBar.items?[1].title = LocalizedKeys.History.title.localized()
        homeTabBar.items?[2].title = LocalizedKeys.Team.tabItemTitle.localized()
        homeTabBar.items?[3].title = LocalizedKeys.Approval.tabItemTitle.localized()
        homeTabBar.items?[4].title = LocalizedKeys.More.title.localized()
        
        self.userUseCase?.setFirebaseToken { firebaseResponse in
            guard let success = firebaseResponse?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if success {
                return
            }
            AlertPresenter.showAlertWithAction(title: LocalizedKeys.General.errorTitle.localized(), message: firebaseResponse?.message ?? "", viewController: self, completion: { _ in
                    self.stopActivityIndicatorSpinner()
            })
        }
    }
    
    /**
     Show spinner.
     */
    func startActivityIndicatorSpinner() {
        DispatchQueue.main.async {
            self.progressHUD.show()
        }
    }
    
    /**
     Hide spinner.
     */
    func stopActivityIndicatorSpinner() {
        DispatchQueue.main.async {
            self.progressHUD.hide()
        }
    }
    
}
