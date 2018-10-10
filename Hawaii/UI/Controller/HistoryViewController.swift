//
//  HistoryViewController.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import EKBlurAlert

class HistoryViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchRequestsSegue = "searchRequests"
    
    let segmentedControl = UISegmentedControl(items: ["All", "Pending", "Approved", "Rejected", "Canceled"])
    
    var customView: UIView = UIView()
    
    var requestUseCase: RequestUseCaseProtocol!
    
    var requests: [Request] = []
    
    var filteredRequests: [Request] = []
    
    var leaveParameter = true
    
    var sickParameter = true
    
    var bonusParameter = true
    
    var selectedYear: String?
    
    var lastTimeSynced: Date?
    
    private let refreshControl = UIRefreshControl()
    
    lazy var filterDisabled: UIBarButtonItem = {
        var buttonImage = UIImage(named: "filter")
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
        var buttonImage = UIImage(named: "filter")
        buttonImage = buttonImage?.withRenderingMode(.alwaysTemplate)
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(buttonImage, for: UIControlState.normal)
        button.addTarget(self, action: #selector(searchRequest), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        button.tintColor = UIColor.accentColor
        
        let item = UIBarButtonItem(customView: button)
        item.tintColor = UIColor.accentColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: RequestDetailTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: RequestDetailTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.primaryColor
        customView.frame = self.view.frame
        self.navigationItem.rightBarButtonItem = filterDisabled
        
        initFilterHeader()
        
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
        segmentedControl.selectedSegmentIndex = 0
        
        let components = Calendar.current.dateComponents([.second], from: lastTimeSynced ?? Date(), to: Date())
        let seconds = components.second ?? Int(Constants.maxTimeElapsed)
        if seconds >= Int(Constants.maxTimeElapsed) {
            if let selectedYear = selectedYear {
                fillCalendatByParameter(year: selectedYear, leave: leaveParameter, sick: sickParameter, bonus: bonusParameter)
            } else {
                fillCalendar()
            }
        }
        lastTimeSynced = Date()
    }
    
    @objc private func refreshData(_ sender: Any) {
        self.refreshControl.endRefreshing()
        if let selectedYear = selectedYear {
            fillCalendatByParameter(year: selectedYear, leave: leaveParameter, sick: sickParameter, bonus: bonusParameter)
        } else {
            fillCalendar()
        }
        lastTimeSynced = Date()
    }
    
    func presentBluredAlertView() {
        let alertView = EKBlurAlertView(frame: self.view.bounds)
        let myImage = UIImage(named: "success") ?? UIImage()
        alertView.setCornerRadius(10)
        alertView.set(autoFade: true, after: 2)
        alertView.set(image: myImage)
        alertView.set(headline: "Success")
        alertView.set(subheading: "You have succesfully canceled a new request")
        view.addSubview(alertView)
    }
    
    func fillCalendatByParameter(year: String, leave: Bool, sick: Bool, bonus: Bool) {
        guard let yearNo = Int(year) else {
            return
        }
        let startDate = "01-01-\(year)"
        let endDate = "31-12-\(year)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        requestUseCase.getAllByDate(from: dateFormatter.date(from: startDate) ?? Date(),
                                    toDate: dateFormatter.date(from: endDate) ?? Date()) { response in
                                        guard let success = response.success else {
                                            self.stopActivityIndicatorSpinner()
                                            return
                                        }
                                        if success {
                                            self.requests = response.item?.filter { self.inSelectedYear(year: yearNo, days: $0.days ?? []) &&
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
                                        } else {
                                            ViewUtility.showAlertWithAction(title: "Error",
                                                                            message: response.message ?? "",
                                                                            viewController: self, completion: { _ in
                                                self.stopActivityIndicatorSpinner()
                                            })
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
            if success {
                self.requests = response.item ?? []
                self.filteredRequests = response.item ?? []
                DispatchQueue.main.async {
                    self.customView.removeFromSuperview()
                    self.segmentedControl.sendActions(for: UIControlEvents.valueChanged)
                    self.stopActivityIndicatorSpinner()
                }
            } else {
                ViewUtility.showAlertWithAction(title: "Error", message: response.message ?? "", viewController: self, completion: { _ in
                    self.stopActivityIndicatorSpinner()
                })
            }
        }
    }
    
    func initFilterHeader() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.accentColor
        segmentedControl.backgroundColor = UIColor.black
        
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
                self.customView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(Constants.dialogBackgroundAlpha))
                self.navigationController?.view.bringSubview(toFront: self.customView)
            })
        }
        self.performSegue(withIdentifier: searchRequestsSegue, sender: nil)
    }

}
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.separatorColor = UIColor.primaryColor
    
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RequestDetailTableViewCell.self), for: indexPath)
            as? RequestDetailTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell.request = filteredRequests[indexPath.row]
        cell.requestCancelationDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        if leaveParameter && sickParameter && bonusParameter {
           self.navigationItem.rightBarButtonItem = filterDisabled
        } else {
            self.navigationItem.rightBarButtonItem = filterEnabled
        }
        fillCalendatByParameter(year: year, leave: leave, sick: sick, bonus: bonus)
    }
    
    func dismissDialog() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }
    
    func inSelectedYear(year: Int, days: [Day]) -> Bool {
        let calendar = Calendar.current
        
        guard let firstDate = days.first?.date,
            let lastDate = days.last?.date else {
                return false
        }
        return calendar.component(.year, from: firstDate) == year ||
                calendar.component(.year, from: lastDate) == year
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
        
        ViewUtility.showConfirmationAlert(message: "Are you sure you want to cancel this request?",
                                          title: "Confirm", viewController: self) { confirmed in
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
            
            if success {
                guard let index = self.tableView.indexPath(for: cell) else {
                    return
                }
                
                let updatedRequest = Request(request: self.filteredRequests[index.row], requestStatus: response.item?.requestStatus)
                let indexOfOldRequest = self.requests.index { $0.id == oldRequest.id }
                
                self.requests[indexOfOldRequest ?? 0] = updatedRequest
                //TODO: Research implications of removing
                if self.filteredRequests[index.row].requestStatus == .pending {
                    self.filteredRequests.remove(at: index.row)
                } else {
                    self.filteredRequests[index.row] = updatedRequest
                }
                self.presentBluredAlertView()
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            } else {
                ViewUtility.showAlertWithAction(title: "Error", message: response.message ?? "", viewController: self, completion: { _ in
                    self.stopActivityIndicatorSpinner()
                })
            }
        }
    }

}
