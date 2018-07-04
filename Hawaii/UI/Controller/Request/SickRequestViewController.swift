//
//  SickRequestViewController.swift
//  Hawaii
//
//  Created by Server on 6/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class SickRequestViewController: BaseViewController {

    let showDatePickerViewControllerSegue = "showDatePickerViewController"
    let showRequestTableViewController = "showRequestTableViewController"
    let showRemainingDaysViewController = "showRemainingDaysViewController"
    
    var datePickerController: DatePickerViewController?
    var requestTableViewController: RequestTableViewController?
    var remainingDaysViewController: RemainigDaysViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showDatePickerViewControllerSegue {
            guard let controller = segue.destination as? DatePickerViewController else {
                return
            }
            self.datePickerController = controller
        } else if segue.identifier == showRequestTableViewController {
            guard let controller = segue.destination as? RequestTableViewController else {
                return
            }
            self.requestTableViewController = controller
            guard let requestTableViewController = self.requestTableViewController else {
                return
            }
            requestTableViewController.requestType = .sick
        } else if segue.identifier == showRemainingDaysViewController {
            guard let controller = segue.destination as? RemainigDaysViewController else {
                return
            }
            self.remainingDaysViewController = controller
            guard let remainingDaysViewController = self.remainingDaysViewController else {
                return
            }
            remainingDaysViewController.mainLabelText = "SICK LEAVE"
        }
    }
}
