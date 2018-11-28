//
//  UserMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class UserManagementViewController: BaseFormViewController {
    
    var user: User?
    
    var userUseCase: UserUseCaseProtocol?
    
    var teamUseCase: TeamUseCaseProtocol?
    
    var leaveProfileUseCase: LeaveProfileUseCaseProtocol?
    
    var teams: [Team]?
    
    var leaveProfiles: [LeaveProfile]?
    
    var selectedTeam: Team?
    
    var selectedLeaveProfile: LeaveProfile?
    
    let progressHUD = ProgressHud(text: LocalizedKeys.General.wait.localized())
    
    lazy var doneBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.black
        self.navigationItem.rightBarButtonItem = doneBarItem
        
        form +++ Section("Basic Info")
            <<< TextRow("fullName") { row in
                row.title = "Full name"
                row.placeholder = "Enter full name"
                row.value = user?.fullName
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                self.setTextInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                self.setTextInput(cell: cell, row: row)
            })
            <<< EmailRow("email") { row in
                row.title = "Email "
                row.placeholder = "Enter email here"
                row.value = user?.email
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setEmailInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setEmailInput(cell: cell, row: row)
            })
            +++ Section("Company info")
            <<< TextRow("jobTitle") { row in
                row.title = "Job title"
                row.placeholder = "Enter Job title"
                row.value = user?.jobTitle
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                self.setTextInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                self.setTextInput(cell: cell, row: row)
            })
            <<< PushRow<String>("userRole") { row in
                row.title = "User role title"
                row.selectorTitle = "Pick user role"
                row.options = ["HR_MANAGER", "APPROVER", "USER"]
                row.value = user?.userRole    // initially selected
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, _ in
                    cell.backgroundColor = UIColor.primaryColor
                    cell.textLabel?.textColor = UIColor.primaryTextColor
            }).cellUpdate({ cell, _ in
                    cell.backgroundColor = UIColor.primaryColor
                    cell.textLabel?.textColor = UIColor.primaryTextColor
            })
            <<< SwitchRow("active") { row in
                row.value = user?.active
                row.title = (user?.active ?? false) ? "Active" : "Not active"
            }.onChange { row in
                row.title = (row.value ?? false) ? "Active": "Not active"
                row.updateCell()
            }.cellSetup { cell, _ in
                self.setSwitchInput(cell: cell)
            }.cellUpdate { cell, _ in
                cell.textLabel?.textColor = UIColor.primaryTextColor
            }
            +++ Section("Additional info")
            <<< IntRow("yearsOfService") {
                $0.title = "Years of service"
                $0.value = user?.yearsOfService
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setIntInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                self.setIntInput(cell: cell, row: row)
            })
            <<< PushRow<String>("team") {
                $0.title = "Team "
                $0.selectorTitle = "Select team"
                $0.value = user?.teamName
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.optionsProvider = .lazy({ form, completion in
                    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    form.tableView.backgroundView = activityView
                    activityView.startAnimating()
                    self.teamUseCase?.get(completion: { response in
                        guard let success = response?.success else {
                            return
                        }
                        if !success {
                            return
                        }
                        self.teams = response?.item
                        form.tableView.backgroundView = nil
                        let teamStringArray = self.teams?.map({ (team: Team) -> String in
                            team.name ?? ""
                        })
                        completion(teamStringArray)
                    })
                    
                })
            }.cellSetup({ cell, _ in
                cell.backgroundColor = UIColor.primaryColor
                cell.textLabel?.textColor = UIColor.primaryTextColor
            }).cellUpdate({ cell, row in
                cell.backgroundColor = UIColor.primaryColor
                cell.textLabel?.textColor = UIColor.primaryTextColor
                self.teams?.forEach({ team in
                    if team.name == row.value {
                        self.selectedTeam = team
                    }
                })
            })
            <<< PushRow<String>("leaveProfile") {
                $0.title = "Leave Profile"
                $0.selectorTitle = "Select profile"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.optionsProvider = .lazy({ form, completion in
                    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    form.tableView.backgroundView = activityView
                    activityView.startAnimating()
                    self.leaveProfileUseCase?.get(completion: { response in
                        guard let success = response?.success else {
                            return
                        }
                        if !success {
                            return
                        }
                        self.leaveProfiles = response?.item
                        form.tableView.backgroundView = nil
                        let leaveProfileStringArray = self.leaveProfiles?.map({ (item: LeaveProfile) -> String in
                            item.name ?? ""
                        })
                        completion(leaveProfileStringArray)
                    })
                    
                })
            }.cellSetup({ cell, _ in
                    cell.backgroundColor = UIColor.primaryColor
                    cell.textLabel?.textColor = UIColor.primaryTextColor
            }).cellUpdate({ cell, row in
                    cell.backgroundColor = UIColor.primaryColor
                    cell.textLabel?.textColor = UIColor.primaryTextColor
                    self.leaveProfiles?.forEach({ item in
                        if item.name == row.value {
                            self.selectedLeaveProfile = item
                        }
                    })
            })
        
    }
    
    @objc func doneEditing() {
        let values = form.values()
        let isValid = form.validate()
        if isValid.isEmpty {
            if let user = user {
                
                let editUser = User(user: user, values: values, team: selectedTeam, leaveProfile: selectedLeaveProfile)
                self.userUseCase?.update(user: editUser, completion: { response in
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
                let newUser = User(values: values, team: selectedTeam, leaveProfile: selectedLeaveProfile)
                self.userUseCase?.add(user: newUser, completion: { response in
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
}
