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
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    var userUseCase: UserUseCaseProtocol?
    
    var user: User?
    
    var selectedTokens: [PushTokenDTO]?
    
    var multivaluedSection: MultivaluedSection?
    
    var multivaluedSection2: MultivaluedSection?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pushTokens = user?.userPushTokens else {
            return
        }
        let deleteAction = SwipeAction(
            style: .destructive,
            title: "Delete",
            handler: { action, row, completionHandler in
                if let rowIndex = row.indexPath?.row {
                    self.deleteFirebaseToken(rowIndex: rowIndex, completion: { success in
                        completionHandler?(success)
                    })
                }
        })
        
        multivaluedSection = MultivaluedSection(multivaluedOptions: [.Reorder, .Delete],
                                                    header: "Multivalued TextFieldjk",
                                                    footer: ".Insert multivaluedOption adds the 'Add New Tag' button row as last cell.") {
                                                        for pushToken in pushTokens {
                                                            $0 <<< TextRow("tag_\(pushToken.pushTokenId)") {
                                                                $0.placeholder = pushToken.platform?.rawValue
                                                                $0.tag = String(describing: pushToken.pushTokenId)
                                                                $0.title = pushToken.name
                                                                $0.trailingSwipe.actions.append(deleteAction)
                                                            }
                                                        }
                                                        
        }
        multivaluedSection2 = MultivaluedSection(multivaluedOptions: [.Reorder, .Delete],
                                                header: "Multivalued TextFieldnm,",
                                                footer: ".Insert multivaluedOption adds the 'Add New Tag' button row as last cell.") {
                                                    for pushToken in pushTokens {
                                                        $0 <<< TextRow("tag2_\(pushToken.pushTokenId)") {
                                                            $0.placeholder = pushToken.platform?.rawValue
                                                            $0.tag = String(describing: pushToken.pushTokenId) + "asdsd"
                                                            $0.title = pushToken.name
                                                            $0.trailingSwipe.actions.append(deleteAction)
                                                        }
                                                    }
        }
        guard let multivaluedSection = multivaluedSection,
              let multivaluedSection2 = multivaluedSection2 else {
            return
        }
        form    +++
            
            multivaluedSection
            
            +++
            
        multivaluedSection2
        
    }
    
    @objc func doneEditing() {
        
    }
    
    func deleteFirebaseToken(rowIndex: Int, completion: @escaping (Bool) -> Void) {
        self.userUseCase?.deleteFirebaseToken { firebaseResponse in
            guard let success = firebaseResponse?.success else {
                completion(false)
                return
            }
            if !success {
                AlertPresenter.showAlertWithAction(title: LocalizedKeys.General.errorTitle.localized(), message: firebaseResponse?.message ?? "",
                                                   viewController: self, completion: { _ in
                    completion(false)
                })
            }
            self.multivaluedSection?.remove(at: rowIndex)
            completion(true)
        }
        
    }
}
