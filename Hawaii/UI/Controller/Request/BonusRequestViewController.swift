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

    var requestTableViewController: RequestTableViewController?
    
    var requestUseCase: RequestUseCaseProtocol?
    
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
            let requestUseCase = requestUseCase,
            let cell = requestTableViewController.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? InputTableViewCell,
            let cellText = cell.inputReasonTextView.text else {
                return
        }
        if startDate > endDate {
            ViewUtility.showAlertWithAction(title: "Error", message: "Dont try to trick me", viewController: self) { _ in
            }
            return
        }
        if cellText == "" || cellText == "Enter reason for leave" {
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
        
        startActivityIndicatorSpinner()
        userUseCase?.getUser(completion: { response in
            
            guard let success = response?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if success {
                let request = Request(approverId: nil, days: days, reason: cellText,
                                      requestStatus: RequestStatus.pending,
                                      absence: requestTableViewController.selectedAbsence, user: response?.item)
                requestUseCase.add(request: request) { requestResponse in
                    
                    guard let success = requestResponse.success else {
                        self.stopActivityIndicatorSpinner()
                        return
                    }
                    if success {
                        guard let request = requestResponse.item else {
                            self.stopActivityIndicatorSpinner()
                            return
                        }
                       // self.requestUpdateDelegate?.didAdd(request: request)
                        self.navigationController?.popViewController(animated: true)
                        self.stopActivityIndicatorSpinner()
                    } else {
                        ViewUtility.showAlertWithAction(title: "Error", message: requestResponse.message ?? "",
                                                        viewController: self, completion: { _ in
                                                            self.stopActivityIndicatorSpinner()
                        })
                    }
                }
                
            } else {
                ViewUtility.showAlertWithAction(title: "Error", message: response?.message ?? "", viewController: self, completion: { _ in
                    self.stopActivityIndicatorSpinner()
                })
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

