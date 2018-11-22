//
//  TeamMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class TeamMenagementViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Basic Info")
            <<< TextRow { row in
                row.title = "Team name"
                row.placeholder = "Enter full name"
            }
            <<< EmailRow {
                $0.title = "Email "
                $0.placeholder = "Enter email here"
            }
            <<< SwitchRow("Active") { row in      // initializer
                    row.title = "Not Active"
            }.onChange { row in
                row.title = (row.value ?? false) ? "Active" : "Not active"
                row.updateCell()
            }.cellSetup { _, _ in
                    
            }.cellUpdate { cell, _ in
                    cell.textLabel?.font = .italicSystemFont(ofSize: 18.0)
            }
        
    }
}
