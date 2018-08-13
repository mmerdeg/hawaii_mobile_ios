//
//  HomeViewController.swift
//  Hawaii
//
//  Created by Server on 6/11/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DashboardViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    
    let formatter = DateFormatter()
    var requestUseCase: RequestUseCaseProtocol?
    var items: [Request] = []
    var customView: UIView = UIView()
    let processor = SVGProcessor()
    let showLeaveRequestSegue = "showLeaveRequest"
    let showSickRequestSegue = "showSickRequest"
    let showBonusRequestSegue = "showBonusRequest"
    let showRequestDetailsSegue = "showRequestDetails"
    
    lazy var addRequestItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRequest))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.textColor = UIColor.primaryTextColor
        nextButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        previousButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        customView.frame = self.view.frame
        let nib = UINib(nibName: String(describing: CalendarCellCollectionViewCell.self), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self))
        // Do any additional setup after loading the view.
        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        setupCalendarView()
        fillCalendar()
        collectionView.scrollToDate(Date(), animateScroll: false)
        self.navigationItem.rightBarButtonItem = addRequestItem
        
    }
    
    @objc func addRequest() {
        
        let leave = DialogWrapper(title: "Leave", uiAction: .default,
                                  handler: { _ in
                                    self.performSegue(withIdentifier: self.showLeaveRequestSegue, sender: nil)
        })
        let sick = DialogWrapper(title: "Sick", uiAction: .default,
                                 handler: { _ in
                                    self.performSegue(withIdentifier: self.showSickRequestSegue, sender: nil)
        })
        let bonus = DialogWrapper(title: "Bonus", uiAction: .default,
                                  handler: { _ in
                                    self.performSegue(withIdentifier: self.showBonusRequestSegue, sender: nil)
        })
        let cancel = DialogWrapper(title: "Cancel", uiAction: .cancel)
        
        ViewUtility.showCustomDialog(self,
                                     choices: [leave, sick, bonus, cancel],
                                     title: "Choose Request Type"
        )
    }
    
    func showDetails(requests: [Request]) {
        self.navigationController?.view.addSubview(customView)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.customView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.navigationController?.view.bringSubview(toFront: self.customView)
            })
        }
        self.performSegue(withIdentifier: showRequestDetailsSegue, sender: requests)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showLeaveRequestSegue {
            guard let controller = segue.destination as? LeaveRequestViewController else {
                return
            }
            controller.requestUpdateDelegate = self
        } else if segue.identifier == showRequestDetailsSegue {
            guard let controller = segue.destination as? RequestDetailsViewController,
                let requests = sender as? [Request] else {
                    return
            }
            controller.requests = requests
            controller.delegate = self
        }
    }
    
    func setupCalendarView() {
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.first?.date else {
                return
            }
            self.formatter.dateFormat = "yyyy"
            let year = self.formatter.string(from: date)
            self.formatter.dateFormat = "MMMM"
            let month = self.formatter.string(from: date)
            self.dateLabel.text = month+", "+year
        }
    }
    
    func fillCalendar() {
        requestUseCase?.getAll { request in
            self.items = request
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func handleCellLeave(cell: CalendarCellCollectionViewCell, cellState: CellState) {
        
    }
    
    @IBAction func nextMonthPressed(_ sender: Any) {
        collectionView.scrollToSegment(.next, triggerScrollToDateDelegate: true,
                                       animateScroll: true, extraAddedOffset: 0.0)
        collectionView.reloadData()
    }
    
    @IBAction func previousMonthPressed(_ sender: Any) {
        collectionView.scrollToSegment(.previous, triggerScrollToDateDelegate: true,
                                       animateScroll: true, extraAddedOffset: 0.0)
    }
}

extension DashboardViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        guard let startDate = formatter.date(from: "01 05 2018"),
            let endDate = formatter.date(from: "31 12 2030") else {
                return ConfigurationParameters(startDate: Date(), endDate: Date(), firstDayOfWeek: .monday)
        }
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
        return parameters
    }
}

extension DashboardViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell,
                  forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self), for: indexPath)
            as? CalendarCellCollectionViewCell else {
                return
        }
        sharedFunctionToConfigureCell(myCustomCell: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self), for: indexPath)
            as? CalendarCellCollectionViewCell else {
                return JTAppleCell()
        }
        
        cell.cellState = cellState
        let calendar = NSCalendar.current
        var requests: [Request] = []
        for item in items {
            guard let days = item.days else {
                continue
            }
            print(cellState.date)
            for day in days where calendar.compare(day.date ?? Date(), to: cellState.date, toGranularity: .day) == .orderedSame {
                let tempRequest = Request(request: item, days: [day])
                requests.append(tempRequest)
            }
        }
        cell.requests = requests.isEmpty || requests.count > 2 ? nil : requests
        cell.setCell(processor: processor)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCellCollectionViewCell else {
            return
        }
        if calendarCell.requests != nil {
            guard let requests = calendarCell.requests else {
                return
            }
            showDetails(requests: requests)
        } else {
            addRequest()
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCellCollectionViewCell else {
            return
        }
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: CalendarCellCollectionViewCell, cellState: CellState, date: Date) {
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView()
    }
    
}

extension DashboardViewController: RequestDetailsDialogProtocol {
    func dismissDialog() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }
    
    func requestTypeClicked(requestType: AbsenceType) {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
        
    }
}

extension DashboardViewController: RequestUpdateProtocol {
    
    func didAdd(request: Request) {
        items.append(request)
        collectionView.reloadData()
    }
    
    func didRemove(request: Request) {
        
    }
    
    func didEdit(request: Request) {
        
    }
    
}
