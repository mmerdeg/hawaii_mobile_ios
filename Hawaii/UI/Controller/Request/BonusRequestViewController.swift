//
//  RequestTypeViewController.swift
//  Hawaii
//
//  Created by Server on 6/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class BonusRequestViewController: BaseViewController {
    
    let showRequestTableViewController = "showRequestTableViewController"

    var requestTableViewController: RequestTableViewController?
    
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.primaryColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showRequestTableViewController {
            guard let controller = segue.destination as? RequestTableViewController else {
                return
            }
            self.requestTableViewController = controller
            controller.startDate = Date()
            guard let requestTableViewController = self.requestTableViewController else {
                return
            }
            requestTableViewController.requestType = .bonus
            addChildViewController(controller)
        } 
    }
}
