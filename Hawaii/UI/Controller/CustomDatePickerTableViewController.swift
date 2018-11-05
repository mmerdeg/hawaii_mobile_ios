import UIKit
import JTAppleCalendar

protocol DatePickerProtocol: class {
    func selectedDate(startDate: Date?, endDate: Date?, isMultipleDaysSelected: Bool)
}

class CustomDatePickerTableViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var okButton: UIButton!
    
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
    
    var isStartSelected = false
    
    let calendarUtils = CalendarUtils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okButton.setTitle(LocalizedKeys.General.ok.localized(), for: .normal)
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
        items = calendarUtils.selectDates(items)
        isStartSelected ? collectionView.scrollToDate(endDate ?? Date(), animateScroll: false)
            : collectionView.scrollToDate(startDate ?? Date(), animateScroll: false)
        fillCalendar()
    }
    
    func setupCalendarView() {
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.last?.date else {
                return
            }
            self.dateLabel.text = self.calendarUtils.formatCalendarHeader(date: date)
        }
    }
    
    func fillCalendar() {
        startActivityIndicatorSpinner()
        self.publicHolidaysUseCase?.getHolidays(completion: { holidays, holidaysResponse in
            guard let success = holidaysResponse?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.handleResponseFaliure(message: holidaysResponse?.message)
                return
            }
            self.holidays = holidays
            
            self.requestUseCase?.getAvailableRequestYears(completion: { yearsResponse in
                guard let success = yearsResponse.success else {
                    self.stopActivityIndicatorSpinner()
                    return
                }
                if !success {
                    self.handleResponseFaliure(message: yearsResponse.message)
                    return
                }
                guard let startYear = yearsResponse.item?.first,
                    let endYear = yearsResponse.item?.last else {
                        return
                }
                self.startDateCalendar = self.calendarUtils.getStartDate(startYear: startYear)
                self.endDateCalendar = self.calendarUtils.getEndDate(endYear: endYear)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.stopActivityIndicatorSpinner()
                    self.collectionView.scrollToDate(Date(), animateScroll: false)
                }
            })
        })
    }
    
    func handleCellLeave(cell: PublicHolidayTableViewCell, cellState: CellState) {
        
    }
    
    @IBAction func closeDialog(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptClicked(_ sender: Any) {
        items = calendarUtils.selectDates(items)
        delegate?.selectedDate(startDate: startDate, endDate: endDate,
                               isMultipleDaysSelected: items.count >= 2 && Calendar.current.compare(startDate ?? Date(),
                                                                                                    to: endDate ?? Date(),
                                                                                                    toGranularity: .day) != .orderedSame)
        self.dismiss(animated: true, completion: nil)
    }
}

extension CustomDatePickerTableViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: startDateCalendar, endDate: endDateCalendar, firstDayOfWeek: .monday)
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
            cell.setCell()
            return cell
        }
        guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: DatePickerCollectionViewCell.self),
                                                  for: indexPath)
                         as? DatePickerCollectionViewCell else {
            return JTAppleCell()
        }
        if cellState.dateBelongsTo == .thisMonth {
            if calendarUtils.containsDate(date: date, items: items) {
                cell.backgroundColor = UIColor.remainingColor
            } else {
                cell.backgroundColor = UIColor.transparentColor
            }
        } else {
            cell.backgroundColor = UIColor.transparentColor
        }
        
        cell.cellState = cellState
        cell.setCell()
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let tempStartDate = startDate
        let tempEndDate = endDate
        
        if isStartSelected {
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
        
        if calendarUtils.isDateOrderValid(startDate: startDate, endDate: endDate) {
            items =  [startDate ?? Date(), endDate ?? Date()]
            items = calendarUtils.selectDates(items)
            collectionView.reloadData()
            return
        }
        AlertPresenter.showAlertWithAction(title: LocalizedKeys.General.errorTitle.localized(),
                                        message: LocalizedKeys.General.trickMessage.localized(),
                                        viewController: self) { _ in
        }
        startDate = tempStartDate
        endDate = tempEndDate
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: PublicHolidayTableViewCell, cellState: CellState, date: Date) {
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView()
    }
}
