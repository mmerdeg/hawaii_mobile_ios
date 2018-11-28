//
//  BaseFormViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import Eureka

class BaseFormViewController: FormViewController {
    
    func setSwitchInput(cell: SwitchCell) {
        cell.switchControl.tintColor = UIColor.accentColor
        cell.backgroundColor = UIColor.primaryColor
        cell.textLabel?.textColor = UIColor.primaryTextColor
        cell.switchControl.onTintColor = UIColor.accentColor
    }
    
    func setEmailInput(cell: EmailCell, row: EmailRow) {
        cell.titleLabel?.textColor = UIColor.primaryTextColor
        cell.textField.textColor = UIColor.primaryTextColor
        row.placeholderColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
        cell.backgroundColor = UIColor.primaryColor
    }
    
    func setIntInput(cell: IntCell, row: IntRow) {
        cell.titleLabel?.textColor = UIColor.primaryTextColor
        cell.textField.textColor = UIColor.primaryTextColor
        row.placeholderColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
        cell.backgroundColor = UIColor.primaryColor
    }
    
    func setTextInput(cell: TextCell, row: TextRow) {
        cell.titleLabel?.textColor = UIColor.primaryTextColor
        cell.textField.textColor = UIColor.primaryTextColor
        row.placeholderColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
        cell.backgroundColor = UIColor.primaryColor
    }
    
    func setDateInput(cell: DateCell, row: DateRow) {
        cell.textLabel?.textColor = UIColor.primaryTextColor
        cell.detailTextLabel?.textColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
        cell.backgroundColor = UIColor.primaryColor
    }
    
}
