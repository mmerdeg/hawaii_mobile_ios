//
//  DatePickerTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/30/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol DatePickerProtocol: class {
    func selectedDate(_ date: Date)
}

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: WhiteUIDatePicker!
    
    weak var delegate: DatePickerProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
