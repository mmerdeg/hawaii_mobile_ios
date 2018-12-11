//
//  TeamsMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class TeamsManagementViewController: BaseViewController {

    @IBOutlet var tableView: UITableView!
    
    var searchableId: Int?
    
    var teamUseCase: TeamUseCase?
    
    var teams: [Team]?
    
    let manageTeamSegue = "manageTeam"
    
    lazy var addBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    lazy var editBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(showEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    lazy var doneBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(showEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: TeamTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: TeamTableViewCell.self))
        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.darkPrimaryColor
        self.view.backgroundColor = UIColor.darkPrimaryColor
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.rightBarButtonItems = [addBarItem, editBarItem]
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillData()
    }
    
    func fillData() {
        startActivityIndicatorSpinner()
        self.teamUseCase?.get(completion: { response in
            guard let success = response?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.stopActivityIndicatorSpinner()
                self.handleResponseFaliure(message: response?.message)
                return
            }
            self.teams = response?.item
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == manageTeamSegue {
            if let team = sender as? Team {
                guard let controller = segue.destination as? TeamManagementViewController else {
                    return
                }
                controller.team = team
            }
        }
    }
    
    @objc func addItem() {
        self.performSegue(withIdentifier: self.manageTeamSegue, sender: nil)
    }
    
    @objc func showEditing() {
        if self.tableView.isEditing == true {
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItems = [addBarItem, editBarItem]
        } else {
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItems = [doneBarItem]
        }
    }

}

extension TeamsManagementViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TeamTableViewCell.self),
                                                       for: indexPath)
            as? TeamTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.team = teams?[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: manageTeamSegue, sender: teams?[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let confirmationAlertTitle = LocalizedKeys.General.confirm.localized()
            let approveAlertMessage = LocalizedKeys.General.deleteMessage.localized()
            
            AlertPresenter.showAlertWithAction(title: confirmationAlertTitle, message: approveAlertMessage, cancelable: true,
                                               viewController: self) { confirmed in
                                                if confirmed {
                                                    guard let selectedTeam = self.teams?[indexPath.row] else {
                                                        return
                                                    }
                                                    self.teamUseCase?.delete(team: selectedTeam, completion: { response in
                                                        guard let success = response?.success else {
                                                            self.stopActivityIndicatorSpinner()
                                                            return
                                                        }
                                                        if !success {
                                                            self.stopActivityIndicatorSpinner()
                                                            self.handleResponseFaliure(message: response?.message)
                                                            return
                                                        }
                                                        self.teams?.remove(at: indexPath.row)
                                                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                                                    })
                                                }
            }
        }
    }
}
