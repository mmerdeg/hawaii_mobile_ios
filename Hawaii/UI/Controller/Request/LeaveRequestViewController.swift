//
//  LeaveRequestViewController.swift
//  Hawaii
//
//  Created by Server on 6/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class LeaveRequestViewController: BaseViewController {
    
    let showDatePickerViewControllerSegue = "showDatePickerViewController"
    
    let showRequestTableViewController = "showRequestTableViewController"
    
    let showRemainingDaysViewController = "showRemainingDaysViewController"
    
    let showSummaryViewController = "showSummaryViewController"
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    
    var requestTableViewController: RequestTableViewController?
    
    var remainingDaysViewController: RemainigDaysViewController?
    
    weak var requestUpdateDelegate: RequestUpdateProtocol?
    
    var userUseCase: UserUseCaseProtocol?
    
    var selectedDate: Date?
    
    lazy var addLeaveRequestItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(addRequest))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = addLeaveRequestItem
        self.scrollView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        
        guard let userInfo = notification.userInfo,
              let value = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {
            return
        }
        var keyboardFrame: CGRect = value.cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
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
            requestTableViewController.delegate = self
            requestTableViewController.requestType = .deducted
            addChildViewController(controller)
        } else if segue.identifier == showRemainingDaysViewController {
            guard let controller = segue.destination as? RemainigDaysViewController else {
                return
            }
            self.remainingDaysViewController = controller
            guard let remainingDaysViewController = self.remainingDaysViewController else {
                return
            }
            remainingDaysViewController.mainLabelText = "Leave"
        } else if segue.identifier == showSummaryViewController {
            guard let controller = segue.destination as? SummaryViewController,
                  let request = sender as? Request else {
                return
            }
            controller.request = request
            controller.requestUpdateDelegate = self.requestUpdateDelegate
            controller.remainingDaysNo = self.remainingDaysViewController?.remainingDayNoLabel.text
        }
    }
    
    @objc func addRequest() {
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
    
    func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        formatter.timeZone = TimeZone(abbreviation: Constants.timeZone)
        return formatter
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

extension LeaveRequestViewController: SelectAbsenceProtocol {
    func didSelect(absence: Absence) {
        if absence.absenceSubtype == "TRAINING" {
            remainingDaysViewController?.mainLabelText = "Training"
        } else {
            remainingDaysViewController?.mainLabelText = "Leave"
        }
    }
}

extension LeaveRequestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      //  self.view.endEditing(true)
    }
}
