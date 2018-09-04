//
//  HistoryViewController.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class HistoryViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchRequestsSegue = "searchRequests"
    
    let segmentedControl = UISegmentedControl(items: ["All", "Pending", "Approved", "Rejected", "Canceled"])
    
    var customView: UIView = UIView()
    
    var requestUseCase: RequestUseCaseProtocol!
    
    var requests: [Request] = []
    
    var filteredRequests: [Request] = []
    
    lazy var searchItem: UIBarButtonItem = {
        
        var buttonImage = UIImage(named: "filter")
        buttonImage = buttonImage?.withRenderingMode(.alwaysTemplate)
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(buttonImage, for: UIControlState.normal)
        button.addTarget(self, action: #selector(searchRequest), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
        button.tintColor = UIColor.primaryTextColor
        
        let item = UIBarButtonItem(customView: button)
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: String(describing: RequestDetailTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: RequestDetailTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.primaryColor
        customView.frame = self.view.frame
        self.navigationItem.rightBarButtonItem = searchItem
        
        initFilterHeader()
        fillCalendar()
    }
    
    func fillCalendar() {
        startActivityIndicatorSpinner()
        requestUseCase.getAll { requests in
            guard let success = requests.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if success {
                self.requests = requests.requests ?? []
                self.filteredRequests = requests.requests ?? []
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            } else {
                ViewUtility.showAlertWithAction(title: "Error", message: requests.message ?? "", viewController: self, completion: { _ in
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == searchRequestsSegue {
            guard let controller = segue.destination as? SearchRequestsViewController else {
                return
            }
            controller.delegate = self
        }
    }
    
    @objc func searchRequest() {
        self.navigationController?.view.addSubview(customView)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.customView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.navigationController?.view.bringSubview(toFront: self.customView)
            })
        }
        self.performSegue(withIdentifier: searchRequestsSegue, sender: nil)
    }

}
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
        return 50
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

    func didFilter(year: String) {
//        requestUseCase.getAllByDate(from: year, toDate: toDate) { requests in
//            self.requests = requests
//            self.tableView.reloadData()
//        }
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }
    
    func dismissDialog() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }
}

extension HistoryViewController: RequestCancelationProtocol {
    
    func requestCanceled(request: Request?, cell: RequestDetailTableViewCell) {
        guard let request = request else {
            return
        }
        var status = RequestStatus.canceled
        if request.requestStatus == .approved {
            status = .cancelationPending
        }
        startActivityIndicatorSpinner()
        requestUseCase.updateRequest(request: Request(request: request, requestStatus: status)) { request in
            
            guard let success = request.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if success {
                if request.request?.requestStatus == RequestStatus.canceled {
                    guard let index = self.tableView.indexPath(for: cell) else {
                        return
                    }
                    self.requests.remove(at: index.row)
                    self.tableView.deleteRows(at: [index], with: UITableViewRowAnimation.left)
                }
            } else {
                ViewUtility.showAlertWithAction(title: "Error", message: request.message ?? "", viewController: self, completion: { _ in
                    self.stopActivityIndicatorSpinner()
                })
            }
        }
    }
    
}
