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
    func selectedDate(_ dates: [Date])
}

class CustomDatePickerTableViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    
    weak var delegate: DatePickerProtocol?
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var publicHolidaysUseCase: PublicHolidayUseCaseProtocol?
    
    var items: [Date] = []
    
    var holidays: [Date: [PublicHoliday]] = [:]
    var customView: UIView = UIView()
    var isFirstSelected = false
    let formatter = DateFormatter()
    let processor = SVGProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.textColor = UIColor.primaryTextColor
        nextButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        previousButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        customView.frame = self.view.frame
        collectionView?.register(UINib(nibName: String(describing: PublicHolidayTableViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: PublicHolidayTableViewCell.self))
        collectionView?.register(UINib(nibName: String(describing: TeamCalendarCollectionViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: TeamCalendarCollectionViewCell.self))
        // Do any additional setup after loading the view.
        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        setupCalendarView()
        collectionView.scrollToDate(items.first ?? Date(), animateScroll: false)
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
            self.dateLabel.text = month+", "+year
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
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.stopActivityIndicatorSpinner()
                }
            } else {
                ViewUtility.showAlertWithAction(title: "Error", message: holidaysResponse?.message ?? "",
                                                viewController: self, completion: { _ in
                                                    self.stopActivityIndicatorSpinner()
                })
            }
        })
    }
    
    func handleCellLeave(cell: PublicHolidayTableViewCell, cellState: CellState) {
        
    }
    
    @IBAction func closeDialog(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextMonthPressed(_ sender: Any) {
        collectionView.scrollToSegment(.next, triggerScrollToDateDelegate: true,
                                       animateScroll: true, extraAddedOffset: 0.0)
        collectionView.reloadData()
    }
    
    @IBAction func acceptClicked(_ sender: Any) {
        delegate?.selectedDate(items)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func previousMonthPressed(_ sender: Any) {
        collectionView.scrollToSegment(.previous, triggerScrollToDateDelegate: true,
                                       animateScroll: true, extraAddedOffset: 0.0)
    }
}

extension CustomDatePickerTableViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Calendar.current.locale
        
        guard let startDate = formatter.date(from: "01 05 2018"),
            let endDate = formatter.date(from: "31 12 2030") else {
                return ConfigurationParameters(startDate: Date(), endDate: Date(), firstDayOfWeek: .monday)
        }
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
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
            guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: TeamCalendarCollectionViewCell.self),
                                                      for: indexPath)
                             as? TeamCalendarCollectionViewCell else {
                return JTAppleCell()
            }
            if cellState.dateBelongsTo == .thisMonth {
                if containsDate(date: date) {
                    cell.backgroundColor = UIColor.blue
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
        if isFirstSelected {
            guard let firstDate = items.first else {
                collectionView.reloadData()
                return
            }
            
            if Calendar.current.compare(firstDate, to: date, toGranularity: .day) == .orderedAscending ||
                Calendar.current.compare(firstDate, to: date, toGranularity: .day) == .orderedSame {
                    items = []
                    items =  [firstDate, date]
                    selectDates()
                    collectionView.reloadData()
            } else {
                ViewUtility.showAlertWithAction(title: "Error", message: "Dont try to trick me", viewController: self) { _ in
                }
            }
            return
        } else {
            items = [date]
            collectionView.reloadData()
            return
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
