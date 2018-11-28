//
//  PublicHolidayMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class PublicHolidayManagementViewController: BaseFormViewController {
    
    var publicHolidayUseCase: PublicHolidayUseCaseProtocol?
    
    var holiday: PublicHoliday?
    
    let progressHUD = ProgressHud(text: LocalizedKeys.General.wait.localized())
    
    lazy var doneBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.primaryColor
        self.navigationItem.rightBarButtonItem = doneBarItem
        form +++ Section("Public holiday info")
            <<< TextRow("name") { row in
                row.title = "Holiday name"
                row.placeholder = "Enter holiday name"
                row.value = holiday?.name
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setTextInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setTextInput(cell: cell, row: row)
            })
            <<< DateRow("date") {
                $0.title = "Holiday date"
                $0.value = holiday?.date ?? Date()
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setDateInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                self.setDateInput(cell: cell, row: row)
            })
            <<< SwitchRow("active") { row in
                row.value = holiday?.active
                row.title = (holiday?.active ?? false) ? "Active" : "Not active"
            }.onChange { row in
                    row.title = (row.value ?? false) ? "Active": "Not active"
                    row.updateCell()
            }.cellSetup { cell, _ in
                    self.setSwitchInput(cell: cell)
            }.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = UIColor.primaryTextColor
            }
        
    }
    
    @objc func doneEditing() {
        let values = form.values()
        let isValid = form.validate()
        if isValid.isEmpty {
            if let holiday = holiday {
                
                let tempHoliday = PublicHoliday(publicHoliday: holiday, values: values)
                self.publicHolidayUseCase?.update(holiday: tempHoliday, completion: { response in
                    guard let success = response.success else {
                        self.stopActivityIndicatorSpinner()
                        return
                    }
                    if !success {
                        self.stopActivityIndicatorSpinner()
                        self.handleResponseFaliure(message: response.message)
                        return
                    }
                    self.popViewController()
                })
            } else {
                let tempHoliday = PublicHoliday(values: values)
                self.publicHolidayUseCase?.add(holiday: tempHoliday, completion: { response in
                    guard let success = response.success else {
                        self.stopActivityIndicatorSpinner()
                        return
                    }
                    if !success {
                        self.stopActivityIndicatorSpinner()
                        self.handleResponseFaliure(message: response.message)
                        return
                    }
                    self.popViewController()
                })
            }
        } else {
            
        }
    }
    
    /**
     Show spinner.
     */
    func startActivityIndicatorSpinner() {
        DispatchQueue.main.async {
            self.progressHUD.show()
        }
    }
    
    /**
     Hide spinner.
     */
    func stopActivityIndicatorSpinner() {
        DispatchQueue.main.async {
            self.progressHUD.hide()
        }
    }
    
    func handleResponseFaliure(message: String?) {
        self.stopActivityIndicatorSpinner()
        AlertPresenter.showAlertWithAction(title: LocalizedKeys.General.errorTitle.localized(), message: message ?? "",
                                           viewController: self, completion: { _ in
        })
    }
}
