//
//  DatePickerViewController.swift
//  Hawaii
//
//  Created by Server on 7/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

class DatePickerViewController: UIViewController {
    
    @IBOutlet weak var startDatePicker: WhiteUIDatePicker!
    
    @IBOutlet weak var endDatePicker: WhiteUIDatePicker!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDatePicker.date = selectedDate ?? Date()
        startDateLabel.textColor = UIColor.secondaryTextColor
        endDateLabel.textColor = UIColor.secondaryTextColor
        endDatePicker.date = selectedDate ?? Date()
    }
}
