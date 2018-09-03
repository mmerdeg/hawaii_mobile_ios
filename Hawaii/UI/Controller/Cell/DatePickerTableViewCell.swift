//
//  DatePickerTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/30/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol DatePickerProtocol: class {
    func selectedDate(_ date: Date, cell: DatePickerTableViewCell)
}

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: WhiteUIDatePicker!
    
    weak var delegate: DatePickerProtocol?
    
    @IBAction func dateSelected(_ sender: Any) {
        delegate?.selectedDate(datePicker.date, cell: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
