//
//  RequestTypeViewController.swift
//  Hawaii
//
//  Created by Server on 6/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class BonusRequestViewController: BaseViewController {
    
    let showRequestTableViewController = "showRequestTableViewController"
    
    let showSummaryViewController = "showSummaryViewController"

    var requestTableViewController: RequestTableViewController?
    
    var userUseCase: UserUseCaseProtocol?
    
    weak var requestUpdateDelegate: RequestUpdateProtocol?
    
    var selectedDate: Date?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var addLeveRequestItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addLeaveRequest))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.primaryColor
        self.navigationItem.rightBarButtonItem = addLeveRequestItem
        self.scrollView.delegate = self
    }
    
    @objc func addLeaveRequest() {
        guard let startDate = requestTableViewController?.startDate,
            let endDate = requestTableViewController?.endDate,
            let requestTableViewController = requestTableViewController,
            let cell = requestTableViewController.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? InputTableViewCell,
            let cellText = cell.inputReasonTextView.text else {
                return
        }
        if startDate > endDate {
            ViewUtility.showAlertWithAction(title: "Error", message: "Dont try to trick me", viewController: self) { _ in
            }
            return
        }
        if cellText.trim() == "" || cellText.trim() == "Enter reason for leave" {
            ViewUtility.showAlertWithAction(title: "Error", message: "Reason filed is required", viewController: self) { _ in
                cell.inputReasonTextView.becomeFirstResponder()
            }
            return
        }
        let durationType = requestTableViewController.getDurationSelection()
        
        var days: [Day] = []
        switch durationType {
        case .afternoonFirst:
            days.append(Day(id: nil, date: startDate, duration: DurationType.afternoon, requestId: nil))
            for currentDate in getDaysBetweeen(startDate: startDate.tomorrow, endDate: endDate) {
                days.append(Day(id: nil, date: currentDate, duration: DurationType.fullday, requestId: nil))
            }
        case .morningLast:
            for currentDate in getDaysBetweeen(startDate: startDate, endDate: endDate.yesterday) {
                days.append(Day(id: nil, date: currentDate, duration: DurationType.fullday, requestId: nil))
            }
            days.append(Day(id: nil, date: endDate, duration: DurationType.morning, requestId: nil))
        case .morningAndAfternoon:
            days.append(Day(id: nil, date: startDate, duration: DurationType.afternoon, requestId: nil))
            for currentDate in getDaysBetweeen(startDate: startDate.tomorrow, endDate: endDate.yesterday) {
                days.append(Day(id: nil, date: currentDate, duration: DurationType.fullday, requestId: nil))
            }
            days.append(Day(id: nil, date: endDate, duration: DurationType.morning, requestId: nil))
        default:
            for currentDate in getDaysBetweeen(startDate: startDate, endDate: endDate) {
                days.append(Day(id: nil, date: currentDate, duration: durationType, requestId: nil))
            }
        }
        
        userUseCase?.readUser(completion: { userResult in
            
            guard let user = userResult else {
                self.stopActivityIndicatorSpinner()
                return
            }
            
            let request = Request(approverId: nil, days: days, reason: cellText.trim(),
                                  requestStatus: RequestStatus.pending,
                                  absence: requestTableViewController.selectedAbsence, user: user)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.showSummaryViewController, sender: request)
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showRequestTableViewController {
            guard let controller = segue.destination as? RequestTableViewController else {
                return
            }
            self.requestTableViewController = controller
            controller.startDate = selectedDate
            guard let requestTableViewController = self.requestTableViewController else {
                return
            }
            requestTableViewController.requestType = .bonus
            addChildViewController(controller)
        } else if segue.identifier == showSummaryViewController {
            guard let controller = segue.destination as? SummaryViewController,
                let request = sender as? Request else {
                    return
            }
            controller.request = request
            controller.requestUpdateDelegate = self.requestUpdateDelegate
            controller.remainingDaysNo = "0"
        }
    }
    
    func getDaysBetweeen(startDate: Date, endDate: Date) -> [Date] {
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        guard let numberOfDays = components.day else {
            return []
        }
        if Calendar.current.compare(startDate, to: endDate, toGranularity: .day) == .orderedSame {
            return [startDate]
        } else if numberOfDays == 0 {
            return [startDate, endDate]
        }
        var dates: [Date] = []
        for currentDay in 0...numberOfDays {
            dates.append(startDate.addingTimeInterval(24 * 3600 * Double(currentDay)))
        }
        return dates
    }
}

extension BonusRequestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
