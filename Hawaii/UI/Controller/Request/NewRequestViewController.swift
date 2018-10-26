//
//  LeaveRequestViewController.swift
//  Hawaii
//
//  Created by Server on 6/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class NewRequestViewController: BaseViewController {
    
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
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var selectedDate: Date?
    
    var absenceType: AbsenceType?
    
    lazy var nextItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(newRequest))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = nextItem
        self.scrollView.delegate = self
        
        guard let absenceType = absenceType else {
            return
        }
        switch absenceType {
        case AbsenceType.sick:
            self.title = "Sickness request"
        case AbsenceType.bonus:
            self.title = "Bonus request"
        default:
            self.title = "Leave request"
        }
        
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let absenceType = absenceType else {
            return false
        }
        return identifier != showRemainingDaysViewController || absenceType != .bonus && absenceType != .sick
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showRequestTableViewController {
            guard let controller = segue.destination as? RequestTableViewController,
                let absenceType = absenceType else {
                return
            }
            self.requestTableViewController = controller
            controller.startDate = selectedDate
            guard let requestTableViewController = self.requestTableViewController else {
                return
            }
            requestTableViewController.delegate = self
            requestTableViewController.requestType = absenceType
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
            controller.remainingDaysNo = self.remainingDaysViewController?.remainingDayNoLabel.text ?? "0"
        }
    }
    
    @objc func newRequest() {
        guard let startDate = requestTableViewController?.startDate,
              let endDate = requestTableViewController?.endDate,
              let requestTableViewController = requestTableViewController,
              let cell = requestTableViewController.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? InputTableViewCell,
              let cellText = cell.inputReasonTextView.text else {
                return
        }
        if startDate > endDate {
            ViewUtility.showAlertWithAction(title: ViewConstants.errorDialogTitle, message: "Dont try to trick me", viewController: self) { _ in
            }
            return
        }
        if cellText.trim() == "" || cellText.trim() == "Enter reason for leave" {
            ViewUtility.showAlertWithAction(title: ViewConstants.errorDialogTitle, message: "Reason filed is required", viewController: self) { _ in
                cell.inputReasonTextView.becomeFirstResponder()
            }
            return
        }
        let durationType = requestTableViewController.getDurationSelection()
        let days = requestUseCase?.populateDaysBetween(startDate: startDate, endDate: endDate, durationType: durationType)
        
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
        return RequestDateFormatter()
    }
}

extension NewRequestViewController: SelectAbsenceProtocol {
    func didSelect(absence: Absence) {
        if absence.absenceSubtype == "TRAINING" {
            remainingDaysViewController?.mainLabelText = "Training"
        } else {
            remainingDaysViewController?.mainLabelText = "Leave"
        }
    }
}

extension NewRequestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.view.endEditing(true)
    }
}
