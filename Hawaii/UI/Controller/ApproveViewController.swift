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
    
    var userUseCase: UserUseCaseProtocol?
    
    var requests: [Request] = []
    
    private let refreshControl = UIRefreshControl()
    
    var lastTimeSynced: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: String(describing: RequestApprovalTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: RequestApprovalTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.primaryColor
        self.navigationController?.navigationBar.barTintColor = UIColor.darkPrimaryColor
        
        // Add Refresh Control to Table View
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.accentColor
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...", attributes: nil)
        fillCalendar()
        lastTimeSynced = Date()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let components = Calendar.current.dateComponents([.second], from: lastTimeSynced ?? Date(), to: Date())
        let seconds = components.second ?? Int(Constants.maxTimeElapsed)
        if seconds >= Int(Constants.maxTimeElapsed) {
            fillCalendar()
        }
        lastTimeSynced = Date()
    }
    
    @objc private func refreshData(_ sender: Any) {
        fillCalendar()
        self.refreshControl.endRefreshing()
        lastTimeSynced = Date()
        
    }
    
    func fillCalendar() {
        startActivityIndicatorSpinner()
        self.requestUseCase.getAllPendingForApprover(approver: -1) { request in
            guard let success = request.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if success {
                self.requests = request.item ?? []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.stopActivityIndicatorSpinner()
                }
            } else {
                self.refreshControl.endRefreshing()
                ViewUtility.showAlertWithAction(title: "Error", message: request.message ?? "", viewController: self, completion: { _ in
                    self.stopActivityIndicatorSpinner()
                })
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
extension ApproveViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.separatorColor = UIColor.primaryColor
        
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
        
        guard let request = request else {
            return
        }
        
        var status: RequestStatus
        var message: String
        if request.requestStatus == .cancelationPending {
            status = isAccepted ? .canceled : .approved
        } else {
            status = isAccepted ? .approved : .rejected
        }
        message = isAccepted ? "Are you sure you want to approve this request?"
                                : "Are you sure you want to reject this request?"
        
        ViewUtility.showConfirmationAlert(message: message, title: "Confirm", viewController: self) { confirmed in
            if confirmed {
                self.updateRequest(request: request, status: status, cell: cell)
            }
        }
    }
    
    func updateRequest(request: Request, status: RequestStatus, cell: RequestApprovalTableViewCell) {
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
