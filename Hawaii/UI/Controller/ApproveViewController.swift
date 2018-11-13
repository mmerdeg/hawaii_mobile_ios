import UIKit
import EKBlurAlert

class ApproveViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var customView: UIView = UIView()
    
    var requestUseCase: RequestUseCaseProtocol!
    
    var userUseCase: UserUseCaseProtocol?
    
    var requests: [Request] = []
    
    var lastTimeSynced: Date?
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControlTitle = LocalizedKeys.General.refresh.localized()
        
        self.navigationItem.title = LocalizedKeys.Approval.title.localized()
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: String(describing: RequestApprovalTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: RequestApprovalTableViewCell.self))
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = UIColor.primaryColor
        self.navigationController?.navigationBar.barTintColor = UIColor.darkPrimaryColor
        
        tableView.backgroundView = EmptyView(frame: tableView.frame,
                                                  titleText: LocalizedKeys.Approval.emptyTitle.localized(),
                                                  descText: LocalizedKeys.Approval.emptyDescription.localized(),
                                                  backgroundImage: #imageLiteral(resourceName: "empty"))
        
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.accentColor
        refreshControl.attributedTitle = NSAttributedString(string: refreshControlTitle, attributes: nil)
        fillCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if RefreshUtils.shouldRefreshData(lastTimeSynced) {
            fillCalendar()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        addObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
    }
    
    /**
     Adds observer for refresh data event.
     */
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData(_:)),
                                               name: NSNotification.Name(rawValue: NotificationNames.refreshData), object: nil)
    }
    
    /**
     Removes observer for refresh data event.
     */
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.refreshData), object: nil)
    }
    
    @objc private func refreshData(_ sender: Any) {
        fillCalendar()
        self.refreshControl.endRefreshing()
    }
    
    func fillCalendar() {
        startActivityIndicatorSpinner()
        self.requestUseCase.getAllPendingForApprover(approver: -1) { response in
            guard let success = response.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.refreshControl.endRefreshing()
                self.handleResponseFaliure(message: response.message)
                return
            }
            self.requests = response.item ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
            self.lastTimeSynced = Date()
        }
    }
}

extension ApproveViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        tableView.separatorColor = UIColor.primaryColor
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RequestApprovalTableViewCell.self), for: indexPath)
            as? RequestApprovalTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.request = requests[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = !requests.isEmpty
        return requests.count
    }
}

extension ApproveViewController: RequestApprovalProtocol {
    
    func requestAction(request: Request?, isAccepted: Bool, cell: RequestApprovalTableViewCell) {
        
        let confirmationAlertTitle = LocalizedKeys.General.confirm.localized()
        let approveAlertMessage = LocalizedKeys.General.approveRequestMessage.localized()
        let rejectAlertMessage = LocalizedKeys.General.rejectRequestMessage.localized()
        
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
        message = isAccepted ? approveAlertMessage : rejectAlertMessage
        
        AlertPresenter.showAlertWithAction(title: confirmationAlertTitle, message: message, cancelable: true,
                                        viewController: self) { confirmed in
            if confirmed {
                self.updateRequest(request: request, status: status, cell: cell, isAccepted: isAccepted)
            }
        }
    }
    
    func updateRequest(request: Request, status: RequestStatus, cell: RequestApprovalTableViewCell, isAccepted: Bool) {
        startActivityIndicatorSpinner()
        requestUseCase.updateRequest(request: Request(request: request, requestStatus: status)) { _ in
            guard let index = self.tableView.indexPath(for: cell) else {
                return
            }
            self.stopActivityIndicatorSpinner()
            
            let alertMessage = isAccepted ? LocalizedKeys.General.approvedRequestMessage.localized()
                : LocalizedKeys.General.rejectedRequestMessage.localized()
            AlertPresenter.presentBluredAlertView(view: self.view, message: alertMessage)
            
            self.requests.remove(at: index.row)
            self.tableView.deleteRows(at: [index], with: UITableViewRowAnimation.left)
        }
    }
}
