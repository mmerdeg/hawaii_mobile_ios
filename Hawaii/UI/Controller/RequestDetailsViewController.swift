//
//  RequestInfoViewController.swift
//  Hawaii
//
//  Created by Server on 6/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol RequestDetailsDialogProtocol: NSObjectProtocol {
    func dismissDialog()
}

class RequestDetailsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var requestDialog: UIView!
    
    @IBOutlet weak var clickableView: UIView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var requestUseCase: RequestUseCaseProtocol!
    
    var userUseCase: UserUseCaseProtocol!
    
    weak var delegate: RequestDetailsDialogProtocol?
    
    var requests: [Request] = []
    
    var isValidUser = false

    override func viewDidLoad() {
        super.viewDidLoad()

        requestDialog.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor.primaryColor.withAlphaComponent(CGFloat(ViewConstants.dialogBackgroundAlpha))
        requestDialog.backgroundColor = UIColor.primaryColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        clickableView.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: String(describing: RequestDetailTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: RequestDetailTableViewCell.self))
        tableView.tableFooterView = UIView()
        
        tableView.layoutIfNeeded()
        heightConstraint.constant = self.tableView.contentSize.height
        getUserStatus()
    }
    
    func getUserStatus() {
        userUseCase.readUser { userResult in
            guard let userId = userResult?.id,
                let requestsUserId = self.requests.first?.user?.id else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if userId == requestsUserId {
                self.isValidUser = true
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func dismissDialog() {
        delegate?.dismissDialog()
        dismiss(animated: true, completion: nil)
    }

}
extension RequestDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.separatorColor = UIColor.primaryColor
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RequestDetailTableViewCell.self), for: indexPath)
            as? RequestDetailTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell.isCancelHidden = !isValidUser
        cell.request = requests[indexPath.row]
        cell.requestCancelationDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
}

extension RequestDetailsViewController: RequestCancelationProtocol {
    
    func requestCanceled(request: Request?, cell: RequestDetailTableViewCell) {
        
        let confirmationAlertTitle = "Confirm"
        let confirmationAlertMessage = "Are you sure you want to cancel this request?"
        
        guard let oldRequest = request,
            let newRequest = request else {
                return
        }
        var status = RequestStatus.canceled
        if oldRequest.requestStatus == .approved {
            status = .canceled
        }
        
        ViewUtility.showAlertWithAction(title: confirmationAlertTitle, message: confirmationAlertMessage,
                                        cancelable: true, viewController: self) { confirmed in
                                            if confirmed {
                                                self.startActivityIndicatorSpinner()
                                                self.updateRequest(request: newRequest, oldRequest: oldRequest, status: status, cell: cell)
                                            }
        }
    }
    
    func updateRequest(request: Request, oldRequest: Request, status: RequestStatus, cell: RequestDetailTableViewCell) {
        requestUseCase.updateRequest(request: Request(request: request, requestStatus: status)) { response in
            
            guard let success = response.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                ViewUtility.showAlertWithAction(title: ViewConstants.errorDialogTitle, message: response.message ?? "",
                                                viewController: self, completion: { _ in
                                                    self.stopActivityIndicatorSpinner()
                })
                return
            }
            
            guard let index = self.tableView.indexPath(for: cell) else {
                return
            }
            let updatedRequest = Request(request: self.requests[index.row], requestStatus: response.item?.requestStatus)
            let indexOfOldRequest = self.requests.index { $0.id == oldRequest.id }
            
            self.requests[indexOfOldRequest ?? 0] = updatedRequest
            
            if self.requests[index.row].requestStatus == .pending {
                self.requests.remove(at: index.row)
            } else {
                self.requests[index.row] = updatedRequest
            }
            self.tableView.reloadData()
            self.stopActivityIndicatorSpinner()
        }
    }
}
