//
//  BaseViewController.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let progressHUD = ProgressHUD(text: "Please wait")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.primaryColor
        self.navigationController?.navigationBar.tintColor = UIColor.primaryTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor.darkPrimaryColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.primaryTextColor]
        self.navigationController?.tabBarController?.tabBar.barTintColor = UIColor.darkPrimaryColor
        self.view.addSubview(progressHUD)
        self.stopActivityIndicatorSpinner()
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.primaryTextColor,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25, weight: .semibold)
            ]
        }
        // Do any additional setup after loading the view.
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
        ViewUtility.showAlertWithAction(title: ViewConstants.errorDialogTitle, message: message ?? "",
                                        viewController: self, completion: { _ in
        })
    }
}
