//
//  LeaveProfilesManagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class LeaveProfilesManagementViewController: BaseViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var leaveProfileUseCase: LeaveProfileUseCase?
    
    var leaveProfiles: [LeaveProfile]?
    
    let manageLeaveProfileSegue = "manageLeaveProfile"
    
    lazy var addBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: LeaveProfileTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: LeaveProfileTableViewCell.self))
        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.darkPrimaryColor
        self.view.backgroundColor = UIColor.darkPrimaryColor
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.rightBarButtonItem = addBarItem
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillData()
    }
    
    func fillData() {
        startActivityIndicatorSpinner()
        self.leaveProfileUseCase?.get(completion: { response in
            guard let success = response?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.stopActivityIndicatorSpinner()
                self.handleResponseFaliure(message: response?.message)
                return
            }
            self.leaveProfiles = response?.item
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == manageLeaveProfileSegue {
            if let leaveProfile = sender as? LeaveProfile {
                guard let controller = segue.destination as? LeaveProfileManagementViewController else {
                    return
                }
                controller.leaveProfile = leaveProfile
            }
        }
    }
    
    @objc func addItem() {
        self.performSegue(withIdentifier: self.manageLeaveProfileSegue, sender: nil)
    }
    
}

extension LeaveProfilesManagementViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaveProfiles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LeaveProfileTableViewCell.self),
                                                       for: indexPath)
            as? LeaveProfileTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.leaveProfile = leaveProfiles?[indexPath.row]
        return cell
        
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: LocalizedKeys.General.delete.localized()) { _, _, handler in
            guard let selectedLeaveProfile = self.leaveProfiles?[indexPath.row] else {
                return
            }
            self.leaveProfileUseCase?.delete(leaveProfile: selectedLeaveProfile, completion: { response in
                guard let success = response?.success else {
                    self.stopActivityIndicatorSpinner()
                    return
                }
                if !success {
                    self.stopActivityIndicatorSpinner()
                    self.handleResponseFaliure(message: response?.message)
                    handler(false)
                    return
                }
                handler(true)
                self.leaveProfiles?.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: manageLeaveProfileSegue, sender: leaveProfiles?[indexPath.row])
    }
}
