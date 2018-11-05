import UIKit
import JTAppleCalendar
import EKBlurAlert

class DashboardViewController: BaseViewController {
    
    let showNewRequestSegue = "showNewRequest"
    
    let showRequestDetailsSegue = "showRequestDetails"
    
    let showRemainingDaysViewController = "showRemainingDaysViewController"
    
    let showRemainingDaysSickViewController = "showRemainingDaysSickViewController"
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var publicHolidaysUseCase: PublicHolidayUseCaseProtocol?
    
    var remainingDaysViewController: RemainigDaysViewController?
    
    var items: [Date: [Request]] = [:]
    
    var holidays: [Date: [PublicHoliday]] = [:]
    
    var customView: UIView = UIView()
    
    var lastTimeSynced: Date?
    
    var startDate = Date()
    
    var endDate = Date()
    
    let formatter = DateFormatter()
    
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
        } else if segue.identifier == showRemainingDaysViewController {
            guard let controller = segue.destination as? RemainigDaysViewController else {
                return
            }
            self.remainingDaysViewController = controller
            guard let remainingDaysViewController = self.remainingDaysViewController else {
                return
            }
            remainingDaysViewController.mainLabelText = LocalizedKeys.RemainingDays.leave.localized()
        } else if segue.identifier == showRemainingDaysSickViewController {
            guard let controller = segue.destination as? RemainigDaysViewController else {
                return
            }
            self.remainingDaysViewController = controller
            guard let remainingDaysViewController = self.remainingDaysViewController else {
                return
            }
            remainingDaysViewController.mainLabelText = LocalizedKeys.RemainingDays.training.localized()
        }
    }
    
    func setupCalendarView() {
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.last?.date else {
                return
            }
            self.formatter.dateFormat = "yyyy"
            let year = self.formatter.string(from: date)
            self.formatter.dateFormat = "MMMM"
            let month = self.formatter.string(from: date).capitalized
            self.dateLabel.text = month+", "+year
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
                    let startDateString = "01 01 \(startYear)"
                    let endDateString = "31 12 \(endYear)"
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MM yyyy"
                    self.startDate = dateFormatter.date(from: startDateString) ?? Date()
                    self.endDate = dateFormatter.date(from: endDateString) ?? Date()
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.stopActivityIndicatorSpinner()
                        
                        self.collectionView.scrollToDate(Date(), animateScroll: false)
                    }
                    self.lastTimeSynced = Date()
                })
            })
        })
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
    
    func presentBluredAlertView() {
        let alertView = EKBlurAlertView(frame: self.view.bounds)
        let myImage = UIImage(named: "success") ?? UIImage()
        alertView.setCornerRadius(10)
        alertView.set(autoFade: true, after: 2)
        alertView.set(image: myImage)
        alertView.set(headline: LocalizedKeys.General.success.localized())
        alertView.set(subheading: LocalizedKeys.Request.addMessage.localized())
        view.addSubview(alertView)
    }
}

extension DashboardViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Calendar.current.locale
        
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
        if holidays.keys.contains(date) {
            
            guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: PublicHolidayTableViewCell.self), for: indexPath)
                as? PublicHolidayTableViewCell else {
                    return JTAppleCell()
            }
            
            cell.cellState = cellState
            cell.setCell()
            return cell
        } else {
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
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCellCollectionViewCell else {
            return
        }
        if calendarCell.requests != nil {
            guard let requests = calendarCell.requests else {
                return
            }
            showDetails(requests)
        } else {
            addRequest(date)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
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
        fillCalendar()
    }
}

extension DashboardViewController: RequestUpdateProtocol {
    
    func didAdd(request: Request) {
        request.days?.forEach({ day in
            if let date = day.date {
                if items[date] != nil {
                    if !(items[date]?.contains(request) ?? true) &&
                        request.requestStatus != RequestStatus.canceled &&
                        request.requestStatus != RequestStatus.rejected &&
                        request.absence?.absenceType != AbsenceType.bonus.rawValue {
                        items[date]?.append(request)
                    }
                } else {
                    items[date] = [request]
                }
            }
        })
        presentBluredAlertView()
        collectionView.reloadData()
        self.collectionView.scrollToDate(request.days?.first?.date ?? Date(), animateScroll: false)
    }
    
    func didRemove(request: Request) {
        
    }
    
    func didEdit(request: Request) {
        
    }
    
}
