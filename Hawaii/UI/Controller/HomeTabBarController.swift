//
//  HomeTabBarController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 10/1/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {
    
    let progressHUD = ProgressHUD(text: "Please wait")
    
    var userUseCase: UserUseCaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        userUseCase?.readUser(completion: { user in
            guard let user = user else {
                return
            }
            if user.userRole != UserRole.hrMenager.rawValue {
                let indexToRemove = 3
                if indexToRemove < self.viewControllers?.count ?? 0 {
                    self.viewControllers?.remove(at: indexToRemove)
                }
            }
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
