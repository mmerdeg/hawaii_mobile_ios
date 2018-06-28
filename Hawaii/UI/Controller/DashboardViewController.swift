//
//  HomeViewController.swift
//  Hawaii
//
//  Created by Server on 6/11/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DashboardViewController: UIViewController {

    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    let formatter = DateFormatter()
    var requestUseCase: RequestUseCaseProtocol!
    var items: [Request] = []
    var customView: UIView = UIView()
    let showLeaveRequestSegue = "showLeaveRequest"
    let showSickRequestSegue = "showSickRequest"
    let showBonusRequestSegue = "showBonusRequest"
    let showRequestDetailsSegue = "showRequestDetails"
    
    lazy var addRequestItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRequest))
        item.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customView.frame = self.view.frame
        let nib = UINib(nibName: String(describing: CalendarCellCollectionViewCell.self), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self))
        // Do any additional setup after loading the view.
        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        setupCalendarView()
        fillCalendar()
        self.navigationItem.rightBarButtonItem = addRequestItem
        
    }
    
    @objc func addRequest() {
        let optionMenu = UIAlertController(title: nil, message: "Choose Request Type", preferredStyle: .actionSheet)
        
        let leaveAction = UIAlertAction(title: "Leave", style: .default) { _ in
            self.performSegue(withIdentifier: self.showLeaveRequestSegue, sender: nil)
        }
        let sickAction = UIAlertAction(title: "Sick", style: .default) { _ in
            self.performSegue(withIdentifier: self.showBonusRequestSegue, sender: nil)
        }
        let bonusAction = UIAlertAction(title: "Bonus", style: .default) { _ in
            self.performSegue(withIdentifier: self.showBonusRequestSegue, sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
        }
        
        optionMenu.addAction(leaveAction)
        optionMenu.addAction(sickAction)
        optionMenu.addAction(bonusAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
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
//            guard let controller = segue.destination as? RequestTypeViewController else {
//                return
//            }
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
        requestUseCase.getAll { request in
            self.items = request
            self.collectionView.reloadData()
            
        }
    }
    
    func handleCellText(cell: CalendarCellCollectionViewCell, cellState: CellState) {
        cell.dateLabel.text = cellState.text
        if Calendar.current.isDateInToday(cellState.date) {
            cell.dateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            cell.dateLabel.textColor = cellState.dateBelongsTo == .thisMonth ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
    func handleCellSelection(cell: CalendarCellCollectionViewCell, cellState: CellState) {
        if Calendar.current.isDateInToday(cellState.date) {
            cell.circleView.isHidden = false
            cell.circleView.backgroundColor = #colorLiteral(red: 1, green: 0.2457885742, blue: 0.2937521338, alpha: 1)
        } else {
            cell.circleView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.circleView.isHidden = cellState.dateBelongsTo == .thisMonth ? !cellState.isSelected : true
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
        
        guard let startDate = formatter.date(from: "01 06 2018"),
              let endDate = formatter.date(from: "31 12 2030") else {
            return ConfigurationParameters(startDate: Date(), endDate: Date())
        }
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
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
            for day in days where calendar.compare(day.date, to: cellState.date, toGranularity: .day) == .orderedSame {
                let tempRequest = Request(request: item, days: [day])
                requests.append(tempRequest)
            }
        }
        cell.requests = requests.isEmpty || requests.count > 2 ? nil : requests
        cell.setCell()
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
        calendarCell.circleView.isHidden = Calendar.current.isDateInToday(cellState.date) ? false : true
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
    
    func requestTypeClicked(requestType: RequestType) {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
        
    }
    
}
