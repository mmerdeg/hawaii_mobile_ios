import UIKit
import JTAppleCalendar
import EKBlurAlert

class DashboardViewController: BaseViewController {
    
    let showNewRequestSegue = "showNewRequest"
    
    let showRequestDetailsSegue = "showRequestDetails"
    
    let showRemainingLeaveDaysViewController = "showRemainingLeaveDaysViewController"
    
    let showRemainingTrainingDaysViewController = "showRemainingTrainingDaysViewController"
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var publicHolidaysUseCase: PublicHolidayUseCaseProtocol?
    
    var remainingLeaveDaysViewController: RemainigDaysViewController?
    
    var remainingTrainingDaysViewController: RemainigDaysViewController?
    
    var items: [Date: [Request]] = [:]
    
    var holidays: [Date: [PublicHoliday]] = [:]
    
    var customView: UIView = UIView()
    
    var lastTimeSynced: Date?
    
    var startDate = Date()
    
    var endDate = Date()

    var lastDateInMonth = Date()
    
    let calendarUtils = CalendarUtils()
    
    lazy var addRequestItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRequestViaItem))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    lazy var refreshItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(fillCalendar))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = LocalizedKeys.Dashboard.title.localized()
        dateLabel.textColor = UIColor.primaryTextColor
        nextButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        previousButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        customView.frame = self.view.frame
        collectionView?.register(UINib(nibName: String(describing: CalendarCellCollectionViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self))
        collectionView?.register(UINib(nibName: String(describing: PublicHolidayTableViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: PublicHolidayTableViewCell.self))
        
        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        collectionView.backgroundColor = UIColor.lightPrimaryColor
        
        self.navigationItem.rightBarButtonItem = addRequestItem
        self.navigationItem.leftBarButtonItem = refreshItem
        fillCalendar()
        setupCalendarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if RefreshUtils.shouldRefreshData(lastTimeSynced) {
            fillCalendar()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        addObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
    }
    
    /**
        Adds observer for refresh data event.
    */
    func addObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(fillCalendar),
                                                   name: NSNotification.Name(rawValue: NotificationNames.refreshData), object: nil)
    }
    
    /**
        Removes observer for refresh data event.
    */
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.refreshData), object: nil)
    }
    
    @objc func addRequestViaItem() {
        addRequest(Date())
    }
    
    func addRequest(_ date: Date? = nil) {
        
        let leave = DialogWrapper(title: LocalizedKeys.Request.leave.localized(), uiAction: .default,
                                  handler: { _ in
                                    self.performSegue(withIdentifier: self.showNewRequestSegue, sender: (date, AbsenceType.deducted))
        })
        let sick = DialogWrapper(title: LocalizedKeys.Request.sickness.localized(), uiAction: .default,
                                 handler: { _ in
                                    self.performSegue(withIdentifier: self.showNewRequestSegue, sender: (date, AbsenceType.sick))
        })
        let bonus = DialogWrapper(title: LocalizedKeys.Request.bonus.localized(), uiAction: .default,
                                  handler: { _ in
                                    self.performSegue(withIdentifier: self.showNewRequestSegue, sender: (date, AbsenceType.bonus))
        })
        let cancel = DialogWrapper(title: LocalizedKeys.General.cancel.localized(), uiAction: .cancel)
        
        AlertPresenter.showCustomDialog(self,
                                     choices: [leave, sick, bonus, cancel],
                                     title: LocalizedKeys.General.newRequestMenu.localized()
        )
    }
    
    func showDetails(_ requests: [Request]) {
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
        if segue.identifier == showNewRequestSegue {
            guard let controller = segue.destination as? NewRequestViewController,
            let data = sender as? (Date, AbsenceType) else {
                return
            }
            let back = UIBarButtonItem()
            back.title = LocalizedKeys.General.back.localized()
            navigationItem.backBarButtonItem = back
            
            controller.selectedDate = data.0
            controller.absenceType = data.1
            controller.requestUpdateDelegate = self
        } else if segue.identifier == showRequestDetailsSegue {
            guard let controller = segue.destination as? RequestDetailsViewController,
                let requests = sender as? [Request] else {
                    return
            }
            controller.requests = requests
            controller.delegate = self
        } else if segue.identifier == showRemainingLeaveDaysViewController {
            guard let controller = segue.destination as? RemainigDaysViewController else {
                return
            }
            self.remainingLeaveDaysViewController = controller
            self.remainingLeaveDaysViewController?.mainLabelText = LocalizedKeys.RemainingDays.leave.localized()
        } else if segue.identifier == showRemainingTrainingDaysViewController {
            guard let controller = segue.destination as? RemainigDaysViewController else {
                return
            }
            self.remainingTrainingDaysViewController = controller
            self.remainingLeaveDaysViewController?.mainLabelText = LocalizedKeys.RemainingDays.leave.localized()
            self.remainingTrainingDaysViewController?.mainLabelText = LocalizedKeys.RemainingDays.training.localized()
        }
    }
    
    func setupCalendarView() {
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.last?.date else {
                return
            }
            self.dateLabel.text = self.calendarUtils.formatCalendarHeader(date: date)
            self.lastDateInMonth = date
        }
    }
    
    @objc func fillCalendar() {
        startActivityIndicatorSpinner()
        
        requestUseCase?.getAllForCalendar(completion: { requestResponse in
            
            guard let success = requestResponse.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.handleResponseFaliure(message: requestResponse.message)
                return
            }
            self.items = requestResponse.item ?? [:]
            
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
                    self.startDate = self.calendarUtils.getStartDate(startYear: startYear)
                    self.endDate = self.calendarUtils.getEndDate(endYear: endYear)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.stopActivityIndicatorSpinner()
                        
                        self.collectionView.scrollToDate(self.lastDateInMonth, animateScroll: false)
                    }
                    self.lastTimeSynced = Date()
                })
            })
        })
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
        return ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
    }
}

extension DashboardViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell,
                  forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
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
        guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self),
                                                      for: indexPath)
            as? CalendarCellCollectionViewCell else {
                return JTAppleCell()
        }
        
        cell.cellState = cellState
        let requests: [Request] = items[date] ?? []
        cell.requests = requests.isEmpty || requests.count > 2 ? nil : requests
        cell.setCell()
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCellCollectionViewCell else {
            return
        }
        if calendarCell.requests == nil {
            addRequest(date)
            return
        }
        guard let requests = calendarCell.requests else {
            return
        }
        showDetails(requests)
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
        fillCalendar()
        remainingLeaveDaysViewController?.getData()
        remainingTrainingDaysViewController?.getData()
    }
}

extension DashboardViewController: RequestUpdateProtocol {
    
    func didAdd(request: Request) {
        request.days?.forEach({ day in
            if let date = day.date {
                if items[date] != nil && !(items[date]?.contains(request) ?? true) &&
                        request.requestStatus != RequestStatus.canceled &&
                        request.requestStatus != RequestStatus.rejected &&
                        request.absence?.absenceType != AbsenceType.bonus.rawValue {
                        items[date]?.append(request)
                } else {
                    items[date] = [request]
                }
            }
        })
        AlertPresenter.presentBluredAlertView(view: self.view,
                                              message: LocalizedKeys.Request.addMessage.localized())
        collectionView.reloadData()
        self.collectionView.scrollToDate(request.days?.first?.date ?? Date(), animateScroll: false)
    }
    
    func didRemove(request: Request) {
    }
    
    func didEdit(request: Request) {
    }
}
