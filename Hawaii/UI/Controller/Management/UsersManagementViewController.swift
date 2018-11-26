//
//  UsersMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class UsersManagementViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userUseCase: UserUseCaseProtocol?
    
    var teamUseCase: TeamUseCaseProtocol?
    
    weak var delegate: RequestDetailsDialogProtocol?
    
    var usersByTeam: [Team]?
    
    let manageUserSegue = "manageUser"
    
    lazy var addBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    lazy var editBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(showEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    lazy var doneBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(showEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: UserPreviewTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: UserPreviewTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.primaryColor
        self.navigationItem.rightBarButtonItem = addBarItem
        self.navigationItem.leftBarButtonItem = editBarItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillData()
    }
    
    @objc func addItem() {
        self.performSegue(withIdentifier: self.manageUserSegue, sender: nil)
    }
    
    @objc func showEditing() {
        if self.tableView.isEditing == true {
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem = addBarItem
            self.navigationItem.leftBarButtonItem = editBarItem
        } else {
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItem = doneBarItem
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == manageUserSegue {
            if let user = sender as? User {
                guard let controller = segue.destination as? UserManagementViewController else {
                    return
                }
                controller.user = user
            }
        }
    }

    func fillData() {
        startActivityIndicatorSpinner()
        self.teamUseCase?.getAll(completion: { users, usersById, response  in
            guard let success = response.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.stopActivityIndicatorSpinner()
                self.handleResponseFaliure(message: response.message)
                return
            }
            self.usersByTeam = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
        })
    }
    
}
extension UsersManagementViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserPreviewTableViewCell.self),
                                                       for: indexPath)
            as? UserPreviewTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.user = Array(users ?? [:])[indexPath.section].value[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = UIColor.primaryTextColor
        label.text = String(describing: Array(users ?? [:])[section].key)
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(users ?? [:])[section].value.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let confirmationAlertTitle = LocalizedKeys.General.confirm.localized()
            let approveAlertMessage = LocalizedKeys.General.deleteMessage.localized()
            
            AlertPresenter.showAlertWithAction(title: confirmationAlertTitle, message: approveAlertMessage, cancelable: true,
                                               viewController: self) { confirmed in
                                                if confirmed {
                                                    let selectedUser = Array(self.users ?? [:])[indexPath.section].value[indexPath.row]
                                                    self.userUseCase?.delete(user: selectedUser, completion: { response in
                                                        guard let success = response?.success else {
                                                            self.stopActivityIndicatorSpinner()
                                                            return
                                                        }
                                                        if !success {
                                                            self.stopActivityIndicatorSpinner()
                                                            self.handleResponseFaliure(message: response?.message)
                                                            return
                                                        }
                                                        var usersInSourceSection = Array(self.users ?? [:])[indexPath.section].value
                                                        let sourceSection = Array(self.users ?? [:])[indexPath.section].key
                                                        usersInSourceSection.remove(at: indexPath.row)
                                                        self.users?[sourceSection] = usersInSourceSection
                                                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                                                    })
                                                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: manageUserSegue, sender: Array(users ?? [:])[indexPath.section].value[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var usersInSourceSection = Array(users ?? [:])[sourceIndexPath.section].value
        let selectedUser = Array(users ?? [:])[sourceIndexPath.section].value[sourceIndexPath.row]
        let sourceSection = String(describing: Array(users ?? [:])[sourceIndexPath.section].key)
        var usersInDestinationSection = Array(users ?? [:])[destinationIndexPath.section].value
        let destinationSection = String(describing: Array(users ?? [:])[destinationIndexPath.section].key)
        
        usersInSourceSection.remove(at: sourceIndexPath.row)
        users?[sourceSection] = usersInSourceSection
        usersInDestinationSection.insert(selectedUser, at: destinationIndexPath.row)
        users?[destinationSection] = usersInDestinationSection
        startActivityIndicatorSpinner()
        let updatedUser = User(user: selectedUser,
                               teamId: usersById?[String(describing: Array(users ?? [:])[destinationIndexPath.section].key)],
                               teamName: destinationSection)
        self.userUseCase?.update(user: updatedUser, completion: { response in
            guard let success = response.success else {
                self.stopActivityIndicatorSpinner()
                self.view.isUserInteractionEnabled = true
                return
            }
            if !success {
                self.handleResponseFaliure(message: response.message)
                self.view.isUserInteractionEnabled = true
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
            
        })
    }
}
