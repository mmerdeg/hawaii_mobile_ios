//
//  TeamMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class TeamManagementViewController: BaseFormViewController {
    
    var teamUseCase: TeamUseCaseProtocol?
    
    var userUseCase: UserUseCaseProtocol?
    
    var team: Team?
    
    var selectedTeamApprovers: [User]?
    
    var pendingRequestWorkItem: DispatchWorkItem?
    
    var searchController: UISearchController?
    
    var approvers: [User]?
    
    let progressHUD = ProgressHud(text: LocalizedKeys.General.wait.localized())

    let showApprovePickerSegue = "showApprovePicker"
    
    lazy var doneBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: nil)
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.searchBar.keyboardAppearance = .dark
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.tintColor = UIColor.white
        searchController?.searchBar.barTintColor = UIColor.white
        searchController?.searchBar.barStyle = .black
        selectedTeamApprovers = team?.teamApprovers
        self.tableView.backgroundColor = UIColor.primaryColor
        self.navigationItem.rightBarButtonItem = doneBarItem
        form +++ Section("Basic Info")
            <<< TextRow("name") { row in
                row.title = LocalizedKeys.TeamManagement.nameTitle.localized()
                row.placeholder = LocalizedKeys.TeamManagement.namePlaceholder.localized()
                row.value = team?.name
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setTextInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setTextInput(cell: cell, row: row)
            })
            <<< EmailRow("email") { row in
                row.title = LocalizedKeys.TeamManagement.emailTitle.localized()
                row.placeholder = LocalizedKeys.TeamManagement.emailPlaceholder.localized()
                row.value = team?.emails
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellSetup({ cell, row in
                    self.setEmailInput(cell: cell, row: row)
            }).cellUpdate({ cell, row in
                    self.setEmailInput(cell: cell, row: row)
            })
            <<< SwitchRow("active") { row in
                row.value = team?.active
                row.title = (team?.active ?? false) ? LocalizedKeys.TeamManagement.activeEnabled.localized() : LocalizedKeys.TeamManagement.activeDisabled.localized()
            }.onChange { row in
                row.title = (row.value ?? false) ? LocalizedKeys.TeamManagement.activeEnabled.localized() : LocalizedKeys.TeamManagement.activeDisabled.localized()
                row.updateCell()
            }.cellSetup { cell, _ in
                    self.setSwitchInput(cell: cell)
            }.cellUpdate { cell, _ in
                    cell.textLabel?.textColor = UIColor.primaryTextColor
            }
            <<< MultipleSelectorRow<User>("teamApprover") {
                $0.title = LocalizedKeys.TeamManagement.teamApproverTitle.localized()
                $0.value = Set(selectedTeamApprovers ?? [])
                $0.optionsProvider = .lazy({ form, completion in
                    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    form.tableView.backgroundView = activityView
                    activityView.startAnimating()
                    self.userUseCase?.getAllApprovers(completion: { response in
                        guard let success = response.success else {
                            return
                        }
                        if !success {
                            return
                        }
                        self.approvers = response.item
                        form.tableView.backgroundView = nil
                        completion(self.approvers)
                    })
                    
                })
                $0.displayValueFor = {
                    $0?.array.map { $0.fullName ?? "" }.sorted().joined(separator: ", ")
                }
            }.onPresent { from, to in
                to.sectionKeyForValue = { $0.fullName?.first?.description ?? "" }
                from.tableView.backgroundColor = UIColor.primaryColor
                to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from,
                                                                           action: #selector(self.multipleSelectorDone))
                
                if #available(iOS 11.0, *) {
                    to.navigationItem.searchController = self.searchController
                }
            }.cellSetup { cell, _ in
                    cell.backgroundColor = UIColor.primaryColor
                    cell.textLabel?.textColor = UIColor.primaryTextColor
            }.cellUpdate { cell, row in
                    cell.backgroundColor = UIColor.primaryColor
                    cell.textLabel?.textColor = UIColor.primaryTextColor
                self.selectedTeamApprovers = row.value?.array
            }
        
    }
    
    @objc func doneEditing() {
        let values = form.values()
        let isValid = form.validate()
        if isValid.isEmpty {
            if let team = team {
                
                let tempTeam = Team(team: team, values: values, teamApprovers: selectedTeamApprovers)
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
                let tempTeam = Team(values: values, teamApprovers: selectedTeamApprovers)
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
    
    @objc func multipleSelectorDone(_ item: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

}

extension TeamManagementViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        pendingRequestWorkItem?.cancel()

        let requestWorkItem = DispatchWorkItem { [weak self] in
            self?.performSearch()
        }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: requestWorkItem)
    }
    
    @objc func performSearch() {
        
    }
}
