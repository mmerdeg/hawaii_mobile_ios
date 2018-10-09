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
    
    var userUseCase: UserUseCaseProtocol?
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.kf.setImage(with: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTuYaHTYdunFCkaR7OwwMXMP_pwTxs_atlJRwBKekLVMl1iQVdag"))
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
