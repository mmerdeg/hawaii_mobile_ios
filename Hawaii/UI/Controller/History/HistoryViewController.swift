import UIKit
import EKBlurAlert

class HistoryViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchRequestsSegue = "searchRequests"
    
    let segmentedControl = UISegmentedControl(items: [LocalizedKeys.History.segmentAll.localized(),
                                                      LocalizedKeys.Request.pending.localized(),
                                                      LocalizedKeys.Request.approved.localized(),
                                                      LocalizedKeys.Request.rejected.localized(),
                                                      LocalizedKeys.Request.canceled.localized()])
    let calendarUtils = CalendarUtils()
    
    var customView: UIView = UIView()
    
    var requestUseCase: RequestUseCase!
    
    var requests: [Request] = []
    
    var filteredRequests: [Request] = []
    
    var leaveParameter = true
    
    var sickParameter = true
    
    var bonusParameter = true
    
    var selectedYear: String?
    
    var lastTimeSynced: Date?
    
    private let refreshControl = UIRefreshControl()
    
    lazy var filterDisabled: UIBarButtonItem = {
        let filterDisabledImageName = "00 filter white 01"
        
        var buttonImage = UIImage(named: filterDisabledImageName)
        buttonImage = buttonImage?.withRenderingMode(.alwaysTemplate)
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(buttonImage, for: UIControlState.normal)
        button.addTarget(self, action: #selector(searchRequest), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 31, height: 21)
        button.tintColor = UIColor.primaryTextColor
        
        let item = UIBarButtonItem(customView: button)
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    lazy var filterEnabled: UIBarButtonItem = {
        let filterEnabledImageName = "00 filter inactive white 01"
        
        var buttonImage = UIImage(named: filterEnabledImageName)
        buttonImage = buttonImage?.withRenderingMode(.alwaysTemplate)
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(buttonImage, for: UIControlState.normal)
        button.addTarget(self, action: #selector(searchRequest), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 51, height: 21)
        button.tintColor = UIColor.primaryTextColor
        
        let item = UIBarButtonItem(customView: button)
        item.tintColor = UIColor.accentColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControlTitle = LocalizedKeys.General.refresh.localized()
        
        self.navigationItem.title = LocalizedKeys.History.title.localized()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: RequestDetailTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: RequestDetailTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.primaryColor
        tableView.backgroundView = EmptyView(frame: tableView.frame,
                                             titleText: LocalizedKeys.History.emptyTitle.localized(),
                                             backgroundImage: #imageLiteral(resourceName: "empty"))
        customView.frame = self.view.frame
        self.navigationItem.rightBarButtonItem = filterDisabled
        
        initFilterHeader()
        
        // Add Refresh Control to Table View
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.accentColor
        refreshControl.attributedTitle = NSAttributedString(string: refreshControlTitle, attributes: nil)
        fillCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.selectedSegmentIndex = 0

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
        self.refreshControl.endRefreshing()
        refreshView()
    }
    
    func refreshView() {
        if let selectedYear = selectedYear {
            fillCalendarByParameter(year: selectedYear, leave: leaveParameter, sick: sickParameter, bonus: bonusParameter)
        } else {
            fillCalendar()
        }
        lastTimeSynced = Date()
    }
    
    func fillCalendarByParameter(year: String, leave: Bool, sick: Bool, bonus: Bool) {
        guard let yearNo = Int(year) else {
            return
        }
        let startDate = calendarUtils.getStartDate(startYear: yearNo)
        let endDate = calendarUtils.getEndDate(endYear: yearNo)

        requestUseCase.getAllByDate(from: startDate, toDate: endDate) { response in
            guard let success = response.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.handleResponseFaliure(message: response.message)
                return
            }
            self.requests = response.item?.filter { self.calendarUtils.inSelectedYear(year: yearNo, days: $0.days ?? []) &&
                (leave ? ($0.absence?.absenceType == AbsenceType.deducted.rawValue ||
                    $0.absence?.absenceType == AbsenceType.nonDecuted.rawValue) : false ||
                    sick ? ($0.absence?.absenceType == AbsenceType.sick.rawValue) : false ||
                    bonus ? ($0.absence?.absenceType == AbsenceType.bonus.rawValue): false)
            } ?? []
            self.filteredRequests = self.requests
            DispatchQueue.main.async {
                self.customView.removeFromSuperview()
                self.segmentedControl.sendActions(for: UIControlEvents.valueChanged)
                self.stopActivityIndicatorSpinner()
            }
        }
    }
    
    func fillCalendar() {
        startActivityIndicatorSpinner()
        requestUseCase.getAll { response in
            guard let success = response.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.handleResponseFaliure(message: response.message)
                return
            }
            self.requests = response.item ?? []
            self.filteredRequests = response.item ?? []
            DispatchQueue.main.async {
                self.customView.removeFromSuperview()
                self.segmentedControl.sendActions(for: UIControlEvents.valueChanged)
                self.stopActivityIndicatorSpinner()
            }
        }
    }
    
    func initFilterHeader() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.accentColor
        segmentedControl.backgroundColor = UIColor.darkPrimaryColor
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)
        let titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.primaryTextColor]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == searchRequestsSegue {
            guard let controller = segue.destination as? SearchRequestsViewController else {
                return
            }
            controller.delegate = self
            controller.leaveParameter = leaveParameter
            controller.sickParameter = sickParameter
            controller.bonusParameter = bonusParameter
            
        }
    }
    
    @objc func searchRequest() {
        self.navigationController?.view.addSubview(customView)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.customView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(ViewConstants.dialogBackgroundAlpha))
                self.navigationController?.view.bringSubview(toFront: self.customView)
            })
        }
        self.performSegue(withIdentifier: searchRequestsSegue, sender: nil)
    }

}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        tableView.separatorColor = UIColor.primaryColor
    
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RequestDetailTableViewCell.self), for: indexPath)
            as? RequestDetailTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.request = filteredRequests[indexPath.row]
        cell.requestCancelationDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = !filteredRequests.isEmpty
        return filteredRequests.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return segmentedControl
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 1:
            filteredRequests = requests.filter { $0.requestStatus == .pending }
        case 2:
            filteredRequests = requests.filter { $0.requestStatus == .approved || $0.requestStatus == .cancelationPending }
        case 3:
            filteredRequests = requests.filter { $0.requestStatus == .rejected }
        case 4:
            filteredRequests = requests.filter { $0.requestStatus == .canceled }
        default:
            filteredRequests = requests
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.segmentedControl.selectedSegmentIndex = segment.selectedSegmentIndex
        }
        
    }
}

extension HistoryViewController: SearchDialogProtocol {
    func didFilterBy(year: String, leave: Bool, sick: Bool, bonus: Bool) {
        leaveParameter = leave
        sickParameter = sick
        bonusParameter = bonus
        selectedYear = year
        
        self.navigationItem.rightBarButtonItem = leaveParameter && sickParameter && bonusParameter ?
            filterDisabled : filterEnabled
        
        fillCalendarByParameter(year: year, leave: leave, sick: sick, bonus: bonus)
    }
    
    func dismissDialog() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }
}

extension HistoryViewController: RequestCancelationProtocol {
    
    func requestCanceled(request: Request?, cell: RequestDetailTableViewCell) {
        guard let oldRequest = request,
                let newRequest = request else {
            return
        }
        var status = RequestStatus.canceled
        if oldRequest.requestStatus == .approved {
            status = .canceled
        }
        
        AlertPresenter.showAlertWithYesNoAction(title: LocalizedKeys.General.confirm.localized(),
                                        message: LocalizedKeys.General.cancelRequestMessage.localized(),
                                        viewController: self) { confirmed in
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
                self.handleResponseFaliure(message: response.message)
                return
            }
            guard let index = self.tableView.indexPath(for: cell) else {
                return
            }
            
            let updatedRequest = Request(request: self.filteredRequests[index.row], requestStatus: response.item?.requestStatus)
            let indexOfOldRequest = self.requests.index { $0.id == oldRequest.id }
            
            self.requests[indexOfOldRequest ?? 0] = updatedRequest
            if self.filteredRequests[index.row].requestStatus == .pending {
                self.filteredRequests.remove(at: index.row)
            } else {
                self.filteredRequests[index.row] = updatedRequest
            }
            AlertPresenter.presentBluredAlertView(view: self.view,
                                                  message: LocalizedKeys.General.canceledRequestMessage.localized())
            self.tableView.reloadData()
            self.stopActivityIndicatorSpinner()
        }
    }

}
