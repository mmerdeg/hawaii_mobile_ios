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
    
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    
    weak var requestUpdateDelegate: RequestUpdateProtocol?
    
    var requestTableViewController: RequestTableViewController?
    
    var remainingDaysViewController: RemainigDaysViewController?
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var userUseCase: UserUseCaseProtocol?
    
    var selectedDate: Date?
    
    lazy var addLeveRequestItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addLeaveRequest))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = addLeveRequestItem
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
        }
    }
    
    @objc func addLeaveRequest() {
        guard let startDate = requestTableViewController?.startDate,
              let endDate = requestTableViewController?.endDate,
              let requestTableViewController = requestTableViewController,
              let requestUseCase = requestUseCase else {
                return
        }
        if startDate > endDate {
            ViewUtility.showAlertWithAction(title: "Error", message: "Dont try to trick me", viewController: self) { _ in
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
            let request = Request(approverId: nil, days: days, reason: "string",
                                  requestStatus: RequestStatus.pending,
                                  absence: requestTableViewController.selectedAbsence, user: response?.user)
            requestUseCase.add(request: request) { request in
                guard let request = request.request else {
                    self.stopActivityIndicatorSpinner()
                    return
                }
                self.requestUpdateDelegate?.didAdd(request: request)
                self.navigationController?.popViewController(animated: true)
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

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon) ?? Date()
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon) ?? Date()
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self) ?? Date()
    }
    
    func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
        let delta = TimeInterval(timeZone.secondsFromGMT() - initTimeZone.secondsFromGMT())
        return addingTimeInterval(delta)
    }
}
