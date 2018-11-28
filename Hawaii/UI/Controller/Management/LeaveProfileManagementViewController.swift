//
//  LeaveProfileManagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class LeaveProfileManagementViewController: BaseFormViewController {
    
    var leaveProfileUseCase: LeaveProfileUseCaseProtocol?
    
    var leaveProfile: LeaveProfile?
    
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
        form +++ Section("Basic Info")
            <<< TextRow("name") { row in
                row.title = "Leave profile name"
                row.placeholder = "Enter leave profile name"
                row.value = leaveProfile?.name
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setTextInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setTextInput(cell: cell, row: row)
            })
            
            <<< TextRow("comment") { row in
                row.title = "Leave profile comment"
                row.placeholder = "Enter leave profile comment"
                row.value = leaveProfile?.comment
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setTextInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setTextInput(cell: cell, row: row)
            })
            <<< IntRow("entitlement") {
                $0.title = "Entitlement"
                $0.value = leaveProfile?.entitlement
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setIntInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setIntInput(cell: cell, row: row)
            })
            <<< IntRow("maxBonusDays") {
                $0.title = "Max bonus days"
                $0.value = leaveProfile?.maxBonusDays
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setIntInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setIntInput(cell: cell, row: row)
            })
            <<< IntRow("maxCarriedOver") {
                $0.title = "Max carried over"
                $0.value = leaveProfile?.maxCarriedOver
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setIntInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setIntInput(cell: cell, row: row)
            })
            <<< IntRow("training") {
                $0.title = "Training"
                $0.value = leaveProfile?.training
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setIntInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setIntInput(cell: cell, row: row)
            })
    }
    
    @objc func doneEditing() {
        let values = form.values()
        let isValid = form.validate()
        if isValid.isEmpty {
            if let leaveProfile = leaveProfile {
                let tempLeaveProfile = LeaveProfile(leaveProfile: leaveProfile, values: values)
                self.leaveProfileUseCase?.update(leaveProfile: tempLeaveProfile, completion: { response in
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
                let tempLeaveProfile = LeaveProfile(values: values)
                self.leaveProfileUseCase?.add(leaveProfile: tempLeaveProfile, completion: { response in
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
    
    @objc func multipleSelectorDone(_ item: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
