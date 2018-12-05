//
//  UserMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class UserManagementViewController: BaseFormViewController, UpdateAllowanceProtocol {
    
    var user: User?
    
    var userUseCase: UserUseCase?
    
    var teamUseCase: TeamUseCase?
    
    var leaveProfileUseCase: LeaveProfileUseCase?
    
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
        
        self.tableView.backgroundColor = UIColor.darkPrimaryColor
        self.navigationItem.rightBarButtonItem = doneBarItem
        
        form +++ Section(LocalizedKeys.UserManagement.basicSection.localized())
            <<< TextRow("fullName") { row in
                row.title = LocalizedKeys.UserManagement.fullNameTitle.localized()
                row.placeholder = LocalizedKeys.UserManagement.fullNamePlaceholder.localized()
                row.value = user?.fullName
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                self.setTextInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                self.setTextInput(cell: cell, row: row)
            })
            <<< EmailRow("email") { row in
                row.title = LocalizedKeys.UserManagement.emailTitle.localized()
                row.placeholder = LocalizedKeys.UserManagement.emailPlaceholder.localized()
                row.value = user?.email
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setEmailInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setEmailInput(cell: cell, row: row)
            })
            +++ Section(LocalizedKeys.UserManagement.companySection.localized())
            <<< TextRow("jobTitle") { row in
                row.title = LocalizedKeys.UserManagement.jobTitleTitle.localized()
                row.placeholder = LocalizedKeys.UserManagement.jobTitlePlaceholder.localized()
                row.value = user?.jobTitle
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                self.setTextInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                self.setTextInput(cell: cell, row: row)
            })
            <<< PushRow<String>("userRole") { row in
                row.title = LocalizedKeys.UserManagement.userRoleTitle.localized()
                row.selectorTitle = LocalizedKeys.UserManagement.userRolePlaceholder.localized()
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
                row.value = user?.userStatusType == StatusType.active
                row.title = user?.userStatusType == StatusType.active ? LocalizedKeys.UserManagement.activeEnabled.localized() :
                    LocalizedKeys.UserManagement.activeDisabled.localized()
            }.onChange { row in
                row.title = (row.value ?? false) ? LocalizedKeys.UserManagement.activeEnabled.localized() :
                    LocalizedKeys.UserManagement.activeDisabled.localized()
                row.updateCell()
            }.cellSetup { cell, _ in
                self.setSwitchInput(cell: cell)
            }.cellUpdate { cell, _ in
                cell.textLabel?.textColor = UIColor.primaryTextColor
            }
            +++ Section(LocalizedKeys.UserManagement.additionalSection.localized()) { section in
                var view = HeaderFooterView<CustomFooter>(.nibFile(name: String(describing: CustomFooter.self), bundle: nil))
                view.onSetupView = { view, _ in
                    view.user = self.user
                }
                section.footer = view
            }
            <<< IntRow("yearsOfService") {
                $0.title = LocalizedKeys.UserManagement.yearsOfServiceTitle.localized()
                $0.value = user?.yearsOfService
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                self.setIntInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                self.setIntInput(cell: cell, row: row)
            })
            <<< PushRow<String>("team") {
                $0.title = LocalizedKeys.UserManagement.teamTitle.localized()
                $0.selectorTitle = LocalizedKeys.UserManagement.teamPlaceholder.localized()
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
                $0.title = LocalizedKeys.UserManagement.leaveProfileTitle.localized()
                $0.selectorTitle = LocalizedKeys.UserManagement.leaveProfilePlaceholder.localized()
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
            <<< ButtonRow("allowance") {
                $0.title = LocalizedKeys.UserManagement.allowance.localized()
                $0.presentationMode = PresentationMode.segueName(segueName: "manageAllowanceSegue", onDismiss: nil)
            }.cellSetup({ cell, _ in
                cell.backgroundColor = UIColor.primaryColor
                cell.textLabel?.textColor = UIColor.primaryTextColor
            }).cellUpdate({ cell, _ in
                cell.backgroundColor = UIColor.primaryColor
                cell.textLabel?.textColor = UIColor.primaryTextColor
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
    
    func didUpdateAllowance(user: User) {
        self.user = user
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manageAllowanceSegue" {
            guard let controller = segue.destination as? AllowanceManagementViewController else {
                return
            }
            controller.user = user
            controller.updateAllowanceDelegate = self
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
