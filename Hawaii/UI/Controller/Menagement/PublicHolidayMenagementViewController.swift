//
//  PublicHolidayMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class PublicHolidayMenagementViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Public holiday info")
            <<< TextRow { row in
                row.title = "Holiday name"
                row.placeholder = "Enter holiday name"
            }
            <<< DateRow {
                $0.title = "Holiday date"
                $0.value = Date()
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
