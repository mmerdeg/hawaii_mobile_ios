//
//  ProfileViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import Eureka

class ProfileViewController: BaseFormViewController {
    
    let progressHUD = ProgressHud(text: LocalizedKeys.General.wait.localized())
    
    lazy var doneBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(doneEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    var userUseCase: UserUseCase?
    
    var userDetailsUseCase: UserDetailsUseCase?
    
    var user: User?
    
    var pushTokens: [PushTokenDTO]?
    
    var deviceSection: MultivaluedSection?
    
    let showTokenDetailsSegue = "showTokenDetails"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = LocalizedKeys.More.tokenScreenTitle.localized()
        self.navigationItem.rightBarButtonItem = doneBarItem
        pushTokens = user?.userPushTokens
        self.tableView.backgroundColor = UIColor.primaryColor
        deviceSection = MultivaluedSection(multivaluedOptions: [.Delete],
                                                    header: "Manage Devices",
                                                    footer: "Manage manage devices which can receive push messages") {
                                                        guard let pushTokens = pushTokens else {
                                                            return
                                                        }
                                                        for pushToken in pushTokens {
                                                            $0 <<< LabelRow("tag_\(String(describing: pushToken.pushTokenId))") {
                                                                $0.value = pushToken.platform?.description
                                                                $0.tag = String(describing: pushToken.pushTokenId)
                                                                if let token = pushToken.pushToken {
                                                                    if token == userDetailsUseCase?.getFirebaseToken() {
                                                                        $0.title = (pushToken.name ?? "") + " (Current device)"
                                                                    } else {
                                                                        $0.title = pushToken.name
                                                                    }
                                                                }
                                                            }.onCellSelection { _, _ in
                                                                self.performSegue(withIdentifier: self.showTokenDetailsSegue, sender: pushToken)
                                                            }.cellSetup({ cell, _ in
                                                                    cell.backgroundColor = UIColor.primaryColor
                                                                    cell.textLabel?.textColor = UIColor.primaryTextColor
                                                                    cell.detailTextLabel?.textColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
                                                            }).cellUpdate({ cell, _ in
                                                                cell.backgroundColor = UIColor.primaryColor
                                                                cell.textLabel?.textColor = UIColor.primaryTextColor
                                                                cell.detailTextLabel?.textColor = UIColor.primaryTextColor.withAlphaComponent(0.7)
                                                            })
                                                        }
                                                        
        }
        guard let deviceSection = deviceSection else {
            return
        }
            form  +++
                
                deviceSection
        
        self.tableView.isEditing = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showTokenDetailsSegue {
            guard let controller = segue.destination as? PushTokenViewController,
                  let pushToken = sender as? PushTokenDTO else {
                return
            }
            controller.pushToken = pushToken
        }
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: LocalizedKeys.General.delete.localized()) { _, _, handler in
                                                self.deleteFirebaseToken(indexPath: indexPath, completion: { isSuccess in
                                                    handler(isSuccess)
                                                })
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard let token = pushTokens?[indexPath.row].pushToken,
              token != userDetailsUseCase?.getFirebaseToken() else {
            return UITableViewCellEditingStyle.none
        }
        return UITableViewCellEditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let confirmationAlertTitle = LocalizedKeys.General.confirm.localized()
            let approveAlertMessage = LocalizedKeys.General.deleteMessage.localized()
            
            AlertPresenter.showAlertWithAction(title: confirmationAlertTitle, message: approveAlertMessage, cancelable: true,
                                               viewController: self) { confirmed in
                                                if confirmed {
                                                    self.deleteFirebaseToken(indexPath: indexPath, completion: { _ in
                                                        
                                                    })
                                                }
            }
        }
    }
    
    @objc func doneEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        doneBarItem.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    func deleteFirebaseToken(indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        guard let pushToken = pushTokens?[indexPath.row].pushToken else {
            completion(false)
            return
        }
        self.userUseCase?.deleteFirebaseToken(pushToken: pushToken) { firebaseResponse in
            guard let success = firebaseResponse?.success else {
                completion(false)
                return
            }
            if !success {
                AlertPresenter.showAlertWithAction(title: LocalizedKeys.General.errorTitle.localized(), message: firebaseResponse?.message ?? "",
                                                   viewController: self, completion: { _ in
                    completion(false)
                })
                return
            }
            self.pushTokens?.remove(at: indexPath.row)
            self.deviceSection?.remove(at: indexPath.row)

            completion(true)
        }
    }
}
