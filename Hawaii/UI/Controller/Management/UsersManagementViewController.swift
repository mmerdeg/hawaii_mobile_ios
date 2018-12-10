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
    
    var userUseCase: UserUseCase?
    
    var teamUseCase: TeamUseCase?
    
    weak var delegate: RequestDetailsDialogProtocol?
    
    var usersByTeam: [GenericExpandableData<Team>?]?
    
    let manageUserSegue = "manageUser"
    
    let headerHeight: CGFloat = 56.0
    
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
        self.navigationItem.rightBarButtonItems = [addBarItem, editBarItem]
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
            self.navigationItem.rightBarButtonItems = [addBarItem, editBarItem]
        } else {
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItems = [doneBarItem]
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
        self.teamUseCase?.getWithExpandableData(completion: { response, expandableData  in
            guard let success = response?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.stopActivityIndicatorSpinner()
                self.handleResponseFaliure(message: response?.message)
                return
            }
            self.usersByTeam = expandableData
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
        cell.user = usersByTeam?[indexPath.section]?.item?.users?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let usersCount = usersByTeam?[section]?.item?.users?.count,
            let isExpanded = usersByTeam?[section]?.isExpanded else {
                return 0
        }
        return isExpanded ? usersCount: 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return usersByTeam?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let collapsableHeader = CollapsableHeader(frame: CGRect(x: 0, y: 0,
                                                                width: self.view.frame.width,
                                                                height: headerHeight),
                                                  section: section,
                                                  teamName: usersByTeam?[section]?.item?.name ?? "",
                                                  isExpanded: usersByTeam?[section]?.isExpanded ?? false)
        collapsableHeader.delegate = self
        return collapsableHeader
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
                                                    self.deleteUser(indexPath: indexPath)
                                                }
            }
        }
    }
    
    func deleteUser(indexPath: IndexPath) {
        guard let selectedUser = self.usersByTeam?[indexPath.section]?.item?.users?[indexPath.row] else {
            return
        }
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
            var usersInSourceSection = self.usersByTeam?[indexPath.section]?.item?.users
            usersInSourceSection?.remove(at: indexPath.row)
            let team = Team(team: self.usersByTeam?[indexPath.row]?.item, users: usersInSourceSection)
            guard let previousData = self.usersByTeam?[indexPath.section] else {
                self.stopActivityIndicatorSpinner()
                return
            }
            self.usersByTeam?[indexPath.section] = GenericExpandableData<Team>(expandableData: previousData,
                                                                               item: team)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: manageUserSegue, sender: usersByTeam?[indexPath.section]?.item?.users?[indexPath.row] )
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var usersInSourceSection = self.usersByTeam?[sourceIndexPath.section]?.item?.users
        var usersInDestinationSection = self.usersByTeam?[destinationIndexPath.section]?.item?.users
        guard let selectedUser = self.usersByTeam?[sourceIndexPath.section]?.item?.users?[sourceIndexPath.row] else {
            return
        }
        let updatedUser = User(user: selectedUser,
                               teamId: usersByTeam?[destinationIndexPath.section]?.item?.id,
                               teamName: usersByTeam?[destinationIndexPath.section]?.item?.name)
        
        startActivityIndicatorSpinner()
        
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
            usersInSourceSection?.remove(at: sourceIndexPath.row)
            var team = Team(team: self.usersByTeam?[sourceIndexPath.section]?.item, users: usersInSourceSection)
            guard let sourceGenericTeam = self.usersByTeam?[sourceIndexPath.section] else {
                self.stopActivityIndicatorSpinner()
                return
            }
            self.usersByTeam?[sourceIndexPath.section] = GenericExpandableData<Team>(expandableData: sourceGenericTeam,
                                                                                item: Team(team: team, users: usersInSourceSection))
            usersInDestinationSection?.insert(selectedUser, at: destinationIndexPath.row)
            team = Team(team: self.usersByTeam?[destinationIndexPath.section]?.item, users: usersInDestinationSection)
            guard let destinationGenericTeam = self.usersByTeam?[sourceIndexPath.section] else {
                self.stopActivityIndicatorSpinner()
                return
            }
            self.usersByTeam?[destinationIndexPath.section] = GenericExpandableData<Team>(expandableData: destinationGenericTeam,
                                                                                     item: Team(team: team, users: usersInDestinationSection))
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
            
        })
    }
}

extension UsersManagementViewController: ExpandProtocol {
    
    func didExpand(section: Int) {
        guard let users = usersByTeam?[section]?.item?.users,
              let isExpanded = usersByTeam?[section]?.isExpanded,
              let team = usersByTeam?[section] else {
            return
        }
        var indexPaths: [IndexPath] = []
        for row in users.indices {
            indexPaths.append(IndexPath(row: row, section: section))
        }
        usersByTeam?[section] = GenericExpandableData<Team>(expandableData: team, isExpanded: !isExpanded)
        if isExpanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .left)
        }
    }

}
