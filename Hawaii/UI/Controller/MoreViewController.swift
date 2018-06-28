//
//  MoreViewController.swift
//  Hawaii
//
//  Created by Server on 6/18/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import GoogleSignIn

class MoreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignOutPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            print("asd")
        } else {
            print("asdsad")
        }
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            print("asd")
        } else {
            print("sadasdas")
        }
    }
}
