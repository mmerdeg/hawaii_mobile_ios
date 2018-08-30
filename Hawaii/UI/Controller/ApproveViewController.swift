//
//  ApproveViewController.swift
//  Hawaii
//
//  Created by Server on 8/13/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class ApproveViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var customView: UIView = UIView()
    
    var requestUseCase: RequestUseCaseProtocol!
    
    var requests: [Request] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: String(describing: RequestApprovalTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: RequestApprovalTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.primaryColor
        self.navigationController?.navigationBar.barTintColor = UIColor.darkPrimaryColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillCalendar()
    }
    
    func fillCalendar() {
        requestUseCase.getAllPendingForApprover(approver: 3) { request in
            self.requests = request
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
extension ApproveViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RequestApprovalTableViewCell.self), for: indexPath)
            as? RequestApprovalTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell.request = requests[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
}

extension ApproveViewController: RequestApprovalProtocol {
    func requestAction(request: Request?, isAccepted: Bool, cell: RequestApprovalTableViewCell) {
        
        var status: RequestStatus
        if request?.requestStatus == .cancelationPending {
            status = isAccepted ? .canceled : .approved
        } else {
            status = isAccepted ? .approved : .rejected
        }
        startActivityIndicatorSpinner()
        requestUseCase.updateRequest(request: Request(request: request,
            requestStatus: status)) { _ in
                guard let index = self.tableView.indexPath(for: cell) else {
                    return
                }
                self.stopActivityIndicatorSpinner()
                self.requests.remove(at: index.row)
                self.tableView.deleteRows(at: [index], with: UITableViewRowAnimation.left)
        }
    }
}
