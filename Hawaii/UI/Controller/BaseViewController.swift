//
//  BaseViewController.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.primaryColor
        self.navigationController?.navigationBar.tintColor = UIColor.primaryTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor.darkPrimaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.primaryTextColor]
        self.navigationController?.tabBarController?.tabBar.barTintColor = UIColor.darkPrimaryColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
