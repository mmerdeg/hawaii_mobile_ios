import UIKit
import JTAppleCalendar

class TeamCalendarViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let teamDetailsSegue = "teamDetails"
    
    let showSearchUserSegue = "showSearchUser"
    
    let calendarUtils = CalendarUtils()
    
    var requestUseCase: RequestUseCase?
    
    var publicHolidaysUseCase: PublicHolidayUseCase?
    
    var userUseCase: UserUseCase?
    
    var lastTimeSynced: Date?
    
    var items: [Date: [Request]] = [:]
    
    var holidays: [Date: [PublicHoliday]] = [:]
    
    var customView: UIView = UIView()
    
    var startDate = Date()
    
    var endDate = Date()
    
    var initialMonth = true
    
    var lastDateInMonth = Date()
    
    var searchableId: Int?
    
    lazy var refreshItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(fillCalendar))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    lazy var searchItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(searchUser))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = LocalizedKeys.Team.title.localized()
        
        dateLabel.textColor = UIColor.primaryTextColor
        nextButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        previousButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        customView.frame = self.view.frame
        
        collectionView?.register(UINib(nibName: String(describing: CalendarCellCollectionViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self))
        collectionView?.register(UINib(nibName: String(describing: TeamCalendarCollectionViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: TeamCalendarCollectionViewCell.self))
        collectionView?.register(UINib(nibName: String(describing: PublicHolidayTableViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: PublicHolidayTableViewCell.self))
        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        collectionView.backgroundColor = UIColor.lightPrimaryColor
        
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: LocalizedKeys.Team.segmentAll.localized(), at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: LocalizedKeys.Team.segmentTeam.localized(), at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: LocalizedKeys.Team.segmentPerson.localized(), at: 2, animated: false)

        self.refreshUI(date: lastDateInMonth)
        initFilterHeader()
        self.navigationItem.leftBarButtonItem = refreshItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lastTimeSynced = Date()
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
    
    @objc func searchUser() {
        self.performSegue(withIdentifier: showSearchUserSegue, sender: nil)
    }
    
    func initFilterHeader() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.accentColor
        segmentedControl.backgroundColor = UIColor.darkPrimaryColor
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)
        let titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.primaryTextColor]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == teamDetailsSegue {
            guard let controller = segue.destination as? TeamPreviewViewController,
                  let requests = sender as? [Request] else {
                    return
            }
            
            controller.requests = Dictionary(grouping: requests, by: { $0.user?.teamName ?? "" })
        } else if segue.identifier == showSearchUserSegue {
            guard let controller = segue.destination as? SearchUsersBaseViewController else {
                return
            }
            controller.delegate = self
        }
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        self.refreshUI(date: lastDateInMonth)
    }
    
    func refreshUI(date: Date) {
        
        self.startActivityIndicatorSpinner()
        
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
                
                switch self.segmentedControl?.selectedSegmentIndex {
                case 0:
                    self.startActivityIndicatorSpinner()
                    self.requestUseCase?.getAllByTeam(from: date, teamId: -1, completion: { requestResponse in
                        self.handle(requestResponse)
                    })
                case 1:
                    self.startActivityIndicatorSpinner()
                    self.userUseCase?.readUser(completion: { user in
                    self.requestUseCase?.getAllByTeam(from: date, teamId: user?.teamId ?? -1, completion: { requestResponse in
                            self.handle(requestResponse)
                        
                        })
                    })
                default:
                    self.startActivityIndicatorSpinner()
                    if let searchableId = self.searchableId {
                        self.requestUseCase?.getAllBy(id: searchableId) { requestResponse in
                            self.handle(requestResponse)
                        }
                        return
                    }
                    self.requestUseCase?.getAllForCalendar { requestResponse in
                        self.handle(requestResponse)
                    }
                }
                self.lastTimeSynced = Date()
            })
        })
        
        if #available(iOS 11.0, *) {
            self.navigationItem.rightBarButtonItem = segmentedControl.selectedSegmentIndex == 2 ? searchItem :  nil
        }
    }
    
    func handle(_ requestResponse: GenericResponse<[Date: [Request]]>?) {
        guard let success = requestResponse?.success else {
            self.stopActivityIndicatorSpinner()
            return
        }
        if !success {
            self.handleResponseFaliure(message: requestResponse?.message)
            return
        }
        self.items = requestResponse?.item ?? [:]
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.stopActivityIndicatorSpinner()
            if self.initialMonth {
                self.collectionView.scrollToDate(self.lastDateInMonth, animateScroll: false)
                self.initialMonth = false
            }
        }
    }
    
    func showDetails(_ requests: [Request]) {
        
        let requestDetailsViewController = "RequestDetailsViewController"
        let dashboardStoryboard = "Dashboard"
        
        if segmentedControl.selectedSegmentIndex != 2 {
            self.performSegue(withIdentifier: teamDetailsSegue, sender: requests)
            return
        }
        self.navigationController?.view.addSubview(customView)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.customView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.navigationController?.view.bringSubview(toFront: self.customView)
            })
        }
        let storyboard = UIStoryboard(name: dashboardStoryboard, bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: requestDetailsViewController)
                                                                    as? RequestDetailsViewController else {
            return
        }
        controller.requests = requests
        controller.delegate = self
        controller.definesPresentationContext = true
        self.present(controller, animated: true, completion: nil)
    }
    
    func setupCalendarView() {
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.last?.date else {
                return
            }
            self.dateLabel.text = self.calendarUtils.formatCalendarHeader(date: date)
            self.lastDateInMonth = date
            self.refreshUI(date: date)
        }
    }
    
    @objc func fillCalendar() {
        refreshUI(date: lastDateInMonth)
    }
    
    func handleCellLeave(cell: CalendarCellCollectionViewCell, cellState: CellState) {
        
    }
    
    @IBAction func nextMonthPressed(_ sender: Any) {
        collectionView.scrollToSegment(.next, triggerScrollToDateDelegate: true,
                                       animateScroll: true, extraAddedOffset: 0.0) {
            self.refreshUI(date: self.lastDateInMonth)
        }
    }
    
    @IBAction func previousMonthPressed(_ sender: Any) {
        collectionView.scrollToSegment(.previous, triggerScrollToDateDelegate: true,
                                       animateScroll: true, extraAddedOffset: 0.0) {
                                        self.refreshUI(date: self.lastDateInMonth)
        }
    }
}

extension TeamCalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
    }
}

extension TeamCalendarViewController: JTAppleCalendarViewDelegate {
    
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
        if segmentedControl.selectedSegmentIndex == 2 {
            guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self),
                                                          for: indexPath) as? CalendarCellCollectionViewCell else {
                return JTAppleCell()
            }
            
            cell.cellState = cellState
            let requests: [Request] = items[date] ?? []
            cell.requests = requests.isEmpty || requests.count > 2 ? nil : requests
            cell.setCell()
            return cell
        }
        guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: TeamCalendarCollectionViewCell.self),
                                                      for: indexPath) as? TeamCalendarCollectionViewCell else {
            return JTAppleCell()
        }
        
        cell.cellState = cellState
        cell.requests = items[date] ?? []
        cell.setCell()
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if let calendarCell = cell as? CalendarCellCollectionViewCell {
            if calendarCell.requests != nil {
                guard let requests = calendarCell.requests else {
                    return
                }
                showDetails(requests)
            }
            return
        }
        
        if let teamCalendarCell = cell as? TeamCalendarCollectionViewCell {
            if teamCalendarCell.requests != nil {
                guard let requests = teamCalendarCell.requests else {
                    return
                }
                showDetails(requests)
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView()
    }
    
}

extension TeamCalendarViewController: RequestDetailsDialogProtocol {
    func dismissDialog() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
            self.refreshUI(date: self.lastDateInMonth)
        }
    }
}

extension TeamCalendarViewController: SearchUserSelectedProtocol {
    func didSelect(user: User) {
        guard let userId = user.id else {
            return
        }
        searchableId = userId
        self.requestUseCase?.getAllBy(id: userId) { requestResponse in
            self.handle(requestResponse)
        }
    }
}
