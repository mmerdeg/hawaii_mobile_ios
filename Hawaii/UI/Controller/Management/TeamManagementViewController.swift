//
//  TeamMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class TeamManagementViewController: FormViewController {
    
    var teamUseCase: TeamUseCaseProtocol?
    
    var team: Team?
    
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
                row.title = "Team name"
                row.placeholder = "Enter team name"
                row.value = team?.name
                
            }.cellSetup({ cell, textRow in
                    cell.titleLabel?.textColor = UIColor.primaryTextColor
                    cell.textField.textColor = UIColor.primaryTextColor
                    textRow.placeholderColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
                    cell.backgroundColor = UIColor.primaryColor
            }).cellUpdate({ cell, textRow in
                    cell.titleLabel?.textColor = UIColor.primaryTextColor
                    cell.textField.textColor = UIColor.primaryTextColor
                    textRow.placeholderColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
                    cell.backgroundColor = UIColor.primaryColor
            })
            <<< EmailRow("email") { row in
                row.title = "Email "
                row.placeholder = "Enter email here"
                row.value = team?.emails
            }.cellSetup({ cell, textRow in
                    cell.titleLabel?.textColor = UIColor.primaryTextColor
                    cell.textField.textColor = UIColor.primaryTextColor
                    textRow.placeholderColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
                    cell.backgroundColor = UIColor.primaryColor
            }).cellUpdate({ cell, textRow in
                    cell.titleLabel?.textColor = UIColor.primaryTextColor
                    cell.textField.textColor = UIColor.primaryTextColor
                    textRow.placeholderColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
                    cell.backgroundColor = UIColor.primaryColor
            })
            <<< SwitchRow("active") { row in
                row.value = team?.active
                row.title = (team?.active ?? false) ? "Active" : "Not active"
            }.onChange { row in
                    row.title = (row.value ?? false) ? "Active": "Not active"
                    row.updateCell()
            }.cellSetup { cell, _ in
                    cell.switchControl.tintColor = UIColor.accentColor
                    cell.backgroundColor = UIColor.primaryColor
                    cell.textLabel?.textColor = UIColor.primaryTextColor
            }.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = UIColor.primaryTextColor
            }
        
    }
    
    @objc func doneEditing() {
        let values = form.values()
        let isValid = form.validate()
        if isValid.isEmpty {
            if let team = team {
                
                let tempTeam = Team(team: team, values: values)
                self.teamUseCase?.update(team: tempTeam, completion: { response in
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
                let tempTeam = Team(values: values)
                self.teamUseCase?.add(team: tempTeam, completion: { response in
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
