//
//  LeaveRequestViewController.swift
//  Hawaii
//
//  Created by Server on 6/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class LeaveRequestViewController: BaseViewController {

    @IBOutlet weak var progressBar: YLProgressBar!
    
    let showDatePickerViewControllerSegue = "showDatePickerViewController"
    let showRequestTableViewController = "showRequestTableViewController"
    
    var datePickerController: DatePickerViewController?
    var requestTableViewController: RequestTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // progressBar.setProgress(0.5, animated: true)
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
        }
    }
    
}

