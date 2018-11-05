//
//  HomeTabBarController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 10/1/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import NotificationBannerSwift

class HomeTabBarController: UITabBarController {
    
    let progressHUD = ProgressHUD(text: "Please wait")
    
    let gcmMessageIDKey = "gcm.message_id"
    
    var userUseCase: UserUseCaseProtocol?
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userUseCase?.readUser(completion: { user in
            if user?.userRole ?? "" != UserRole.hrMenager.rawValue {
                let indexToRemove = 3
                if self.viewControllers?.count ?? 0 == 5 {
                    DispatchQueue.main.async {
                        self.viewControllers?.remove(at: indexToRemove)
                    }
                }
            }
        })
        
        self.userUseCase?.setFirebaseToken { firebaseResponse in
            guard let success = firebaseResponse?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                ViewUtility.showAlertWithAction(title: ViewConstants.errorDialogTitle, message: firebaseResponse?.message ?? "",
                                                viewController: self, completion: { _ in
                                                    self.stopActivityIndicatorSpinner()
                })
            }
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
