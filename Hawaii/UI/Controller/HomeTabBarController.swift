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
        homeTabBar.tintColor = UIColor.primaryTextColor
        homeTabBar.unselectedItemTintColor = UIColor.tabBarItemColor
        userUseCase?.readUser(completion: { user in
            guard let user = user else {
                return
            }
            if user.userRole ?? "" != UserRole.hrManager.rawValue && self.viewControllers?.count ?? 0 == 5 {
                DispatchQueue.main.async {
                    let indexToRemove = 3
                    self.viewControllers?.remove(at: indexToRemove)
                    self.homeTabBar.items?[0].title = LocalizedKeys.Dashboard.title.localized()
                    self.homeTabBar.items?[1].title = LocalizedKeys.History.title.localized()
                    self.homeTabBar.items?[2].title = LocalizedKeys.Team.tabItemTitle.localized()
                    self.homeTabBar.items?[3].title = self.homeTabBar.items?.count == 3 ? LocalizedKeys.More.title.localized() :
                        LocalizedKeys.Approval.tabItemTitle.localized()
                    self.homeTabBar.items?[4].title = LocalizedKeys.More.title.localized()
                }
            }
        })
    
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
