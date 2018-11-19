//
//  UserMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class UserMenagementViewController: FormViewController {
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.primaryColor
        form +++ Section("Basic Info")
            <<< TextRow { row in
                row.title = "Full name"
                row.placeholder = "Enter full name"
                row.value = user?.fullName
            }
            <<< EmailRow { row in
                row.title = "Email "
                row.placeholder = "Enter email here"
                row.value = user?.email
            }
            +++ Section("Company info")
            <<< TextRow { row in
                row.title = "Job title"
                row.placeholder = "Enter Job title"
                row.value = user?.jobTitle
            }
            <<< PushRow<String> { row in
                row.title = "User role title"
                row.selectorTitle = "Pick user role"
                row.options = ["HR_MANAGER", "APPROVER", "USER"]
                row.value = user?.userRole    // initially selected
                
            }
            <<< SwitchRow("Active") { row in
                row.value = user?.active
                row.title = (user?.active ?? false) ? "Active" : "Not active"
            }.onChange { row in
                row.title = (row.value ?? false) ? "Active": "Not active"
                row.updateCell()
            }.cellSetup { _, _ in
                
            }.cellUpdate { _, _ in
                
            }
            +++ Section("Additional info")
            <<< IntRow {
                $0.title = "Years of service"
                $0.value = user?.yearsOfService ?? 0
            }
            <<< PushRow<String> {
                $0.title = "Team "
                $0.selectorTitle = "Select team"
                $0.options = ["team 1", "team 2", "team 3"]
                $0.value = user?.teamName
                
            }
    }
}
