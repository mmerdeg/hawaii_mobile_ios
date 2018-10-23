//
//  CustomDatePickerTableViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/5/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol DatePickerProtocol: class {
    func selectedDate(startDate: Date?, endDate: Date?, isMultipleDaysSelected: Bool)
}

class CustomDatePickerTableViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    
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
        closeButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        customView.frame = self.view.frame
        collectionView?.register(UINib(nibName: String(describing: PublicHolidayTableViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: PublicHolidayTableViewCell.self))
        collectionView?.register(UINib(nibName: String(describing: DatePickerCollectionViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: DatePickerCollectionViewCell.self))

        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        
        setupCalendarView()
        items = [startDate ?? Date(), endDate ?? Date()]
        selectDates()
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
        startActivityIndicatorSpinner()
        self.publicHolidaysUseCase?.getHolidays(completion: { holidays, holidaysResponse in
            guard let success = holidaysResponse?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if success {
                self.holidays = holidays
                self.requestUseCase?.getAvailableRequestYears(completion: { yearsResponse in
                    guard let success = yearsResponse.success else {
                        self.stopActivityIndicatorSpinner()
                        return
                    }
                    if success {
                        guard let startYear = yearsResponse.item?.first,
                            let endYear = yearsResponse.item?.last else {
                                return
                        }
                        let startDateString = "01 01 \(startYear)"
                        let endDateString = "31 12 \(endYear)"
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd MM yyyy"
                        self.startDateCalendar = dateFormatter.date(from: startDateString) ?? Date()
                        self.endDateCalendar = dateFormatter.date(from: endDateString) ?? Date()
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.stopActivityIndicatorSpinner()
                            
                            self.collectionView.scrollToDate(Date(), animateScroll: false)
                        }
                    } else {
                        self.stopActivityIndicatorSpinner()
                        ViewUtility.showAlertWithAction(title: "Error", message: holidaysResponse?.message ?? "",
                                                        viewController: self, completion: { _ in
                        })
                    }
                    
                })
                
            } else {
                
                self.stopActivityIndicatorSpinner()
                ViewUtility.showAlertWithAction(title: "Error", message: holidaysResponse?.message ?? "",
                                                viewController: self, completion: { _ in
                })
            }
        })
    }
    
    func handleCellLeave(cell: PublicHolidayTableViewCell, cellState: CellState) {
        
    }
    
    @IBAction func closeDialog(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptClicked(_ sender: Any) {
        selectDates()
        delegate?.selectedDate(startDate: startDate, endDate: endDate,
                               isMultipleDaysSelected: items.count >= 2 && Calendar.current.compare(startDate ?? Date(),
                                                                                                    to: endDate ?? Date(),
                                                                                                    toGranularity: .day) != .orderedSame)
        self.dismiss(animated: true, completion: nil)
    }
}

extension CustomDatePickerTableViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Calendar.current.locale
        
        let parameters = ConfigurationParameters(startDate: startDateCalendar, endDate: endDateCalendar, firstDayOfWeek: .monday)
        return parameters
    }
}

extension CustomDatePickerTableViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell,
                  forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: PublicHolidayTableViewCell.self), for: indexPath)
            as? PublicHolidayTableViewCell else {
                return
        }
        sharedFunctionToConfigureCell(myCustomCell: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        if holidays.keys.contains(date) {
            
            guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: PublicHolidayTableViewCell.self), for: indexPath)
                             as? PublicHolidayTableViewCell else {
                    return JTAppleCell()
            }
            
            cell.cellState = cellState
            cell.setCell(processor: processor)
            return cell
        } else {
            guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: DatePickerCollectionViewCell.self),
                                                      for: indexPath)
                             as? DatePickerCollectionViewCell else {
                return JTAppleCell()
            }
            if cellState.dateBelongsTo == .thisMonth {
                if containsDate(date: date) {
                    cell.backgroundColor = UIColor.remainingColor
                } else {
                    cell.backgroundColor = UIColor.transparentColor
                }
            } else {
                cell.backgroundColor = UIColor.transparentColor
            }
            
            cell.cellState = cellState
            cell.setCell(processor: processor)
            return cell
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let tempStartDate = startDate
        let tempEndDate = endDate
        if isFirstSelected {
            endDate = date
        } else {
            startDate = date
            if Calendar.current.compare(startDate ?? Date(), to: endDate ?? Date(), toGranularity: .day) == .orderedDescending {
                endDate = startDate
            } else if items.count >= 2 && Calendar.current.compare(tempStartDate ?? Date(),
                                                                   to: tempEndDate ?? Date(),
                                                                   toGranularity: .day) == .orderedSame {
                endDate = startDate
            }
        }
        if Calendar.current.compare(startDate ?? Date(), to: endDate ?? Date(), toGranularity: .day) == .orderedAscending ||
            Calendar.current.compare(startDate ?? Date(), to: endDate ?? Date(), toGranularity: .day) == .orderedSame {
            items = []
            items =  [startDate ?? Date(), endDate ?? Date()]
            selectDates()
            collectionView.reloadData()
        } else {
            ViewUtility.showAlertWithAction(title: "Error", message: "Dont try to trick me", viewController: self) { _ in
            }
            startDate = tempStartDate
            endDate = tempEndDate
        }
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: PublicHolidayTableViewCell, cellState: CellState, date: Date) {
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView()
    }
    
    func selectDates() {
        var date = items.first ?? Date()// first date
        let endDate = items.last ?? Date()// last date
        
        if Calendar.current.compare(date, to: endDate, toGranularity: .day) == .orderedSame {
            items = [date, date]
        } else {
            items = [date]
            while date < endDate {
                guard let selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
                    return
                }
                date = selectedDate
                items.append(selectedDate)
            }
        }
    }
    
    func containsDate(date: Date) -> Bool {
        for tempDate in items {
            if Calendar.current.compare(date, to: tempDate, toGranularity: .day) == .orderedSame {
                return true
            }
        }
        return false
    }
    
}
