//
//  UsersMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class UsersMenagementViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userUseCase: UserUseCaseProtocol?
    
    weak var delegate: RequestDetailsDialogProtocol?
    
    var users: [String: [User]]?
    
    let menageUserSegue = "menageUser"
    
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
        fillData()
    }
    
    @objc func addItem() {
        let addUser = DialogWrapper(title: LocalizedKeys.Request.sickness.localized(), uiAction: .default,
                                    handler: { _ in
                                        self.performSegue(withIdentifier: self.menageUserSegue, sender: nil)
        })
        let cancel = DialogWrapper(title: LocalizedKeys.General.cancel.localized(), uiAction: .cancel)
        
        AlertPresenter.showCustomDialog(self,
                                        choices: [addUser, cancel],
                                        title: LocalizedKeys.General.newRequestMenu.localized()
        )
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

    func fillData() {
        startActivityIndicatorSpinner()
        self.userUseCase?.getAll(completion: { users, response in
            guard let success = response.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.stopActivityIndicatorSpinner()
                self.handleResponseFaliure(message: response.message)
                return
            }
            self.users = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
        })
    }
    
}
extension UsersMenagementViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: menageUserSegue, sender: Array(users ?? [:])[indexPath.section].value[indexPath.row] )
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
    }
}
