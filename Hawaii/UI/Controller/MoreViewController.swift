//
//  MoreViewController.swift
//  Hawaii
//
//  Created by Server on 6/18/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import GoogleSignIn

class MoreViewController: BaseViewController {

    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onSignOutPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        removeToken()
        navigateToSignIn()
    }
    
    func removeToken() {
        guard let userDetailsUseCase = userDetailsUseCase else {
            return
        }
        userDetailsUseCase.setToken(token: "")
    }
    
    func navigateToSignIn() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else {
                return
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let signInViewController = mainStoryboard.instantiateViewController (withIdentifier: "SignInViewController")
            as? SignInViewController else {
                return
        }
        
        window.rootViewController = signInViewController
        window.makeKeyAndVisible()
    }
}
