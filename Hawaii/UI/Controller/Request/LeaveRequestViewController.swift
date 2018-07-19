//
//  LeaveRequestViewController.swift
//  Hawaii
//
//  Created by Server on 6/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class LeaveRequestViewController: BaseViewController {
    
    let showDatePickerViewControllerSegue = "showDatePickerViewController"
    let showRequestTableViewController = "showRequestTableViewController"
    let showRemainingDaysViewController = "showRemainingDaysViewController"

    var datePickerController: DatePickerViewController?
    var requestTableViewController: RequestTableViewController?
    var remainingDaysViewController: RemainigDaysViewController?
    
    lazy var addLeveRequestItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addLeaveRequest))
        item.tintColor = UIColor.accentColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = addLeveRequestItem
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
            requestTableViewController.requestType = .vacation
        } else if segue.identifier == showRemainingDaysViewController {
            guard let controller = segue.destination as? RemainigDaysViewController else {
                return
            }
            self.remainingDaysViewController = controller
            guard let remainingDaysViewController = self.remainingDaysViewController else {
                return
            }
            remainingDaysViewController.mainLabelText = "LEAVE"
        }
    }
    
    @objc func addLeaveRequest() {
//        guard let startDate = datePickerController?.startDatePicker.date,
//            let endDate = datePickerController?.endDatePicker.date,
//            let requestTableViewController = requestTableViewController? else {
//                return
//        }
//        let leaveType = requestTableViewController.getTypeSelection()
//        let duration = requestTableViewController.getDurationSelection()
        
//        let request = Request(id: Int?, days: [Day]?, reason: String?, requestStatus: <#T##RequestStatus?#>, absence: <#T##Absence?#>)
        
        
    }
    
}
