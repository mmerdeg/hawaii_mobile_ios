//
//  TeamCalendarViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar

class TeamCalendarViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var resultsController: UITableViewController?
    var searchController: UISearchController?
    
    let teamDetailsSegue = "teamDetails"
    
    let requestDetailsViewController = "RequestDetailsViewController"
    
    let processor = SVGProcessor()
    
    let formatter = DateFormatter()
    var requestUseCase: RequestUseCaseProtocol?
    var userUseCase: UserUseCaseProtocol?
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    var lastTimeSynced: Date?
    
    var page = 0
    var numberOfItems = 10
    
    var items: [Request] = []
    var users: [User] = []
    var customView: UIView = UIView()
    var timer: Timer?
    
    var searchableId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.textColor = UIColor.primaryTextColor
        nextButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        previousButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        customView.frame = self.view.frame
        collectionView?.register(UINib(nibName: String(describing: CalendarCellCollectionViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self))
        collectionView?.register(UINib(nibName: String(describing: TeamCalendarCollectionViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: TeamCalendarCollectionViewCell.self))
        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        collectionView.backgroundColor = UIColor.lightPrimaryColor
        
        collectionView.scrollToDate(Date(), animateScroll: false)
        initFilterHeader()
        setUpSearch()
        setupCalendarView()
        lastTimeSynced = Date()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let components = Calendar.current.dateComponents([.second], from: lastTimeSynced ?? Date(), to: Date())
        let seconds = components.second ?? Int(Constants.maxTimeElapsed)
        if seconds >= Int(Constants.maxTimeElapsed) {
            setupCalendarView()
        }
        lastTimeSynced = Date()
    }
    
    func setUpSearch() {
        
        let nib = UINib(nibName: String(describing: UserPreviewTableViewCell.self), bundle: nil)
        resultsController = UITableViewController(style: .grouped)
        resultsController?.tableView.dataSource = self
        resultsController?.tableView.delegate = self
        resultsController?.tableView.register(nib, forCellReuseIdentifier: String(describing: UserPreviewTableViewCell.self))
        resultsController?.tableView.register(UINib(nibName: String(describing: LoadMoreTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: LoadMoreTableViewCell.self))
        resultsController?.tableView.tableFooterView = UIView()
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.tintColor = UIColor.white
        searchController?.searchBar.barTintColor = UIColor.white
        searchController?.searchBar.barStyle = .black
        self.definesPresentationContext = true
    }
    
    func initFilterHeader() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.accentColor
        segmentedControl.backgroundColor = UIColor.black
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
            
            controller.requests = Dictionary(grouping: requests, by: { $0.user?.teamId ?? -1 })
        }
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.last?.date else {
                return
            }
            self.refreshUI(date: date)
        }
    }
    
    func refreshUI(date: Date) {
        switch self.segmentedControl?.selectedSegmentIndex {
        case 0:
            self.startActivityIndicatorSpinner()
            self.requestUseCase?.getAllByTeam(from: date, teamId: -1, completion: { requestResponse in
                self.handleResponse(requestResponse: requestResponse)
            })
        case 1:
            self.startActivityIndicatorSpinner()
            self.userUseCase?.readUser(completion: { user in
                self.requestUseCase?.getAllByTeam(from: date, teamId: user?.teamId ?? -1, completion: { requestResponse in
                    self.handleResponse(requestResponse: requestResponse)
                })
            })
        default:
            self.startActivityIndicatorSpinner()
            if let searchableId = searchableId {
                self.requestUseCase?.getAllBy(id: searchableId) { requestResponse in
                    self.handleResponse(requestResponse: requestResponse)
                }
            } else {
                self.requestUseCase?.getAll { requestResponse in
                    self.handleResponse(requestResponse: requestResponse)
                }
            }
        }
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = segmentedControl.selectedSegmentIndex == 2 ? searchController : nil
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func handleResponse(requestResponse: GenericResponse<[Request]>?) {
        guard let success = requestResponse?.success else {
            self.stopActivityIndicatorSpinner()
            return
        }
        if success {
            self.items = requestResponse?.item ?? []
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
        } else {
            ViewUtility.showAlertWithAction(title: "Error", message: requestResponse?.message ?? "", viewController: self, completion: { _ in
                self.stopActivityIndicatorSpinner()
            })
        }
    }
    
    func showDetails(_ requests: [Request]) {
        switch segmentedControl.selectedSegmentIndex {
        case 2:
            self.navigationController?.view.addSubview(customView)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.customView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    self.navigationController?.view.bringSubview(toFront: self.customView)
                })
            }
            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: requestDetailsViewController)
                                                                        as? RequestDetailsViewController else {
                return
            }
            controller.requests = requests
            controller.delegate = self
            controller.definesPresentationContext = true
            self.present(controller, animated: true, completion: nil)
        default:
            self.performSegue(withIdentifier: teamDetailsSegue, sender: requests)
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
            let month = self.formatter.string(from: date)
            self.dateLabel.text = month+", "+year
            self.refreshUI(date: date)
        }
    }
    
    func fillCalendar() {
        startActivityIndicatorSpinner()
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.last?.date else {
                return
            }
            self.requestUseCase?.getAllByTeam(from: date, teamId: -1, completion: { requestResponse in
                self.handleResponse(requestResponse: requestResponse)
            })
        }
    }
    
    func handleCellLeave(cell: CalendarCellCollectionViewCell, cellState: CellState) {
        
    }
    
    @IBAction func nextMonthPressed(_ sender: Any) {
        collectionView.scrollToSegment(.next, triggerScrollToDateDelegate: true,
                                       animateScroll: true, extraAddedOffset: 0.0)
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.last?.date else {
                return
            }
            self.refreshUI(date: date)
        }
    }
    
    @IBAction func previousMonthPressed(_ sender: Any) {
        collectionView.scrollToSegment(.previous, triggerScrollToDateDelegate: true,
                                       animateScroll: true, extraAddedOffset: 0.0)
        collectionView.visibleDates { visibleDates in
            guard let date = visibleDates.monthDates.last?.date else {
                return
            }
            self.refreshUI(date: date)
        }
    }
}

extension TeamCalendarViewController: JTAppleCalendarViewDataSource {
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

extension TeamCalendarViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell,
                  forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self), for: indexPath)
            as? CalendarCellCollectionViewCell else {
                return
        }
        sharedFunctionToConfigureCell(myCustomCell: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        if segmentedControl.selectedSegmentIndex == 2 {
            guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self),
                                                          for: indexPath)
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
                for day in days where calendar.compare(day.date ?? Date(), to: cellState.date, toGranularity: .day) == .orderedSame &&
                    item.requestStatus != RequestStatus.canceled &&
                    item.requestStatus != RequestStatus.rejected &&
                    item.absence?.absenceType != AbsenceType.bonus.rawValue {
                    let tempRequest = Request(request: item, days: [day])
                    requests.append(tempRequest)
                }
            }
            cell.requests = requests.isEmpty || requests.count > 2 ? nil : requests
            cell.setCell(processor: processor)
            return cell
        } else {
            guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: TeamCalendarCollectionViewCell.self),
                                                          for: indexPath)
                as? TeamCalendarCollectionViewCell else {
                    return JTAppleCell()
            }
            
            cell.cellState = cellState
            let calendar = NSCalendar.current
            var requests: [Request] = []
            for item in items {
                guard let days = item.days else {
                    continue
                }
                for day in days where calendar.compare(day.date ?? Date(), to: cellState.date, toGranularity: .day) == .orderedSame &&
                    item.requestStatus != RequestStatus.canceled &&
                    item.requestStatus != RequestStatus.rejected &&
                    item.absence?.absenceType != AbsenceType.bonus.rawValue {
                    let tempRequest = Request(request: item, days: days)
                    requests.append(tempRequest)
                }
            }
            cell.requests = requests
            cell.setCell(processor: processor)
            return cell
        }

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if let calendarCell = cell as? CalendarCellCollectionViewCell {
            if calendarCell.requests != nil {
                guard let requests = calendarCell.requests else {
                    return
                }
                showDetails(requests)
            }
        } else {
            if let teamCalendarCell = cell as? TeamCalendarCollectionViewCell {
                if teamCalendarCell.requests != nil {
                    guard let requests = teamCalendarCell.requests else {
                        return
                    }
                    showDetails(requests)
                }
            } else {
                return
            }
        }
        
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: CalendarCellCollectionViewCell, cellState: CellState, date: Date) {
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView()
    }
    
    func getUsers(parameter: String, page: Int, numberOfItems: Int, completion: @escaping () -> Void) {
        userUseCase?.getUsersByParameter(parameter: parameter, page: page, numberOfItems: numberOfItems, completion: { response in
            guard let success = response.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if success {
                guard let users = response.users,
                    let usersMax = response.maxUsers else {
                        return
                }
                if !users.isEmpty {
                    if self.page == 0 {
                        self.users = []
                    }
                    self.page += 1
                    for user in users {
                        self.users.append(user)
                    }
                }
                self.userDetailsUseCase?.setLoadMore(self.users.count < usersMax)
                self.resultsController?.tableView.reloadData()
                completion()
            } else {
                ViewUtility.showAlertWithAction(title: "Error", message: response.message ?? "", viewController: self, completion: { _ in
                    self.stopActivityIndicatorSpinner()
                })
            }
        })
    }
    
}

extension TeamCalendarViewController: RequestDetailsDialogProtocol {
    func dismissDialog() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }
}

extension TeamCalendarViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        timer?.invalidate()  // Cancel any previous timer
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
    }
    
    @objc func performSearch() {
        self.users = []
        self.page = 0
        getUsers(parameter: searchController?.searchBar.text ?? "", page: 0, numberOfItems: numberOfItems) {
            
        }
    }
}

extension TeamCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.isEmpty {
            tableView.backgroundView?.isHidden = false
            return 0
        } else {
            guard let loadMore = userDetailsUseCase?.getLoadMore() else {
                return users.count
            }
            if loadMore {
                return users.count + 1
            } else {
                return users.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == users.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier:
                String(describing: LoadMoreTableViewCell.self)) as? LoadMoreTableViewCell else {
                    let defaultCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
                    return defaultCell
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserPreviewTableViewCell.self),
                                                           for: indexPath)
                as? UserPreviewTableViewCell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell.user = users[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == users.count {
            guard let loadMoreCell = tableView.cellForRow(at: indexPath) as? LoadMoreTableViewCell else {
                return
            }
            loadMoreCell.activityIndicator.startAnimating()
            loadMoreCell.loadMore.isHidden = true
            loadMoreCell.loadingMore.isHidden = false
            getUsers(parameter: searchController?.searchBar.text ?? "", page: page, numberOfItems: numberOfItems) {
                
            }
        } else {
            guard let cell = tableView.cellForRow(at: indexPath) as? UserPreviewTableViewCell else {
                    return
            }
            self.searchController?.dismiss(animated: true, completion: nil)
            self.searchableId = cell.user?.id
            self.requestUseCase?.getAllBy(id: cell.user?.id ?? -1) { requestResponse in
                self.handleResponse(requestResponse: requestResponse)
            }
        }
    }
}
