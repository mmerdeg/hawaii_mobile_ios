//
//  CalendarViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 10/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: DatePickerProtocol?
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var publicHolidaysUseCase: PublicHolidayUseCaseProtocol?
    
    var startDate: Date?
    
    var endDate: Date?
    
    var startDateCalendar = Date()
    var endDateCalendar = Date()
    
    var items: [Date] = []
    
    var holidays: [Date: [PublicHoliday]] = [:]
    var customView: UIView = UIView()
    var isFirstSelected = false
    let formatter = DateFormatter()
    let processor = SVGProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.textColor = UIColor.primaryTextColor
        customView.frame = self.view.frame
        
        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        
        setupCalendarView()
        items = [startDate ?? Date(), endDate ?? Date()]
        isFirstSelected ? collectionView.scrollToDate(endDate ?? Date(), animateScroll: false)
            : collectionView.scrollToDate(startDate ?? Date(), animateScroll: false)
        fillCalendar()
    }
    
    func setupCalendarView() {
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.last?.date else {
                return
            }
            self.formatter.dateFormat = "yyyy"
            let year = self.formatter.string(from: date)
            self.formatter.dateFormat = "MMMM"
            let month = self.formatter.string(from: date)
            self.dateLabel.text = month + ", " + year
        }
    }
    func fillCalendar() {
        
    }
    
    func handleCellLeave(cell: PublicHolidayTableViewCell, cellState: CellState) {
        
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Calendar.current.locale
        
        let parameters = ConfigurationParameters(startDate: startDateCalendar, endDate: endDateCalendar, firstDayOfWeek: .monday)
        return parameters
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell,
                  forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: PublicHolidayTableViewCell.self), for: indexPath)
            as? PublicHolidayTableViewCell else {
                return
        }
        sharedFunctionToConfigureCell(myCustomCell: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        return JTAppleCell()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: PublicHolidayTableViewCell, cellState: CellState, date: Date) {
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView()
    }
    
}
