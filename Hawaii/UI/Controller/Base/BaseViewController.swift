import UIKit

class BaseViewController: UIViewController {
    
    let progressHUD = ProgressHud(text: LocalizedKeys.General.wait.localized())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.primaryColor
        self.navigationController?.navigationBar.tintColor = UIColor.primaryTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor.darkPrimaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primaryTextColor]
        self.navigationController?.tabBarController?.tabBar.barTintColor = UIColor.darkPrimaryColor
        self.view.addSubview(progressHUD)
        self.stopActivityIndicatorSpinner()
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primaryTextColor,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .semibold)
            ]
        }
        NotificationCenter.default.addObserver(self, selector: #selector(changeColorScheme),
                                               name: NSNotification.Name(rawValue: NotificationNames.themeChanged), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func handleResponseFaliure(message: String?) {
        self.stopActivityIndicatorSpinner()
        AlertPresenter.showAlertWithAction(title: LocalizedKeys.General.errorTitle.localized(), message: message ?? "",
                                        viewController: self, completion: { _ in
                                            self.stopActivityIndicatorSpinner()
        })
    }
    
    @objc func changeColorScheme() {
        
        self.view.setNeedsDisplay()
        self.navigationController?.view.setNeedsDisplay()
        
        for subview in self.view.subviews {
            subview.setNeedsDisplay()
        }
    }
}
