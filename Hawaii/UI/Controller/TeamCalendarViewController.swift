//
//  TeamCalendarViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar

class TeamCalendarViewController: SearchUsersBaseViewController {
    
    @IBOutlet weak var collectionView: JTAppleCalendarView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let teamDetailsSegue = "teamDetails"
    
    let requestDetailsViewController = "RequestDetailsViewController"
    
    let processor = SVGProcessor()
    
    let formatter = DateFormatter()
    var requestUseCase: RequestUseCaseProtocol?
    var publicHolidaysUseCase: PublicHolidayUseCaseProtocol?
    var lastTimeSynced: Date?
    
    var items: [Date: [Request]] = [:]
    var holidays: [Date: [PublicHoliday]] = [:]
    var customView: UIView = UIView()
    
    var lastDateInMonth = Date()
    var searchableId: Int?
    lazy var refreshItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(fillCalendar))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
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
        collectionView?.register(UINib(nibName: String(describing: PublicHolidayTableViewCell.self), bundle: nil),
                                 forCellWithReuseIdentifier: String(describing: PublicHolidayTableViewCell.self))
        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        collectionView.backgroundColor = UIColor.lightPrimaryColor
        
        collectionView.scrollToDate(Date(), animateScroll: false)
        initFilterHeader()
        lastTimeSynced = Date()
        self.navigationItem.leftBarButtonItem = refreshItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let components = Calendar.current.dateComponents([.second], from: lastTimeSynced ?? Date(), to: Date())
        let seconds = components.second ?? Int(Constants.maxTimeElapsed)
        if seconds >= Int(Constants.maxTimeElapsed) {
            self.refreshUI(date: lastDateInMonth)
        }
        lastTimeSynced = Date()
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
        self.refreshUI(date: lastDateInMonth)
    }
    
    override func didSelect(user: User) {
        super.didSelect(user: user)
        guard let userId = user.id else {
            return
        }
        searchableId = userId
        self.requestUseCase?.getAllBy(id: userId) { requestResponse in
            self.handle(requestResponse)
        }
    }
    
    func refreshUI(date: Date) {
        switch self.segmentedControl?.selectedSegmentIndex {
        case 0:
            self.startActivityIndicatorSpinner()
            self.publicHolidaysUseCase?.getHolidays(completion: { holidays, holidaysResponse in
                guard let success = holidaysResponse?.success else {
                    self.stopActivityIndicatorSpinner()
                    return
                }
                if success {
                    self.holidays = holidays
                    self.requestUseCase?.getAllByTeam(from: date, teamId: -1, completion: { requestResponse in
                        self.handle(requestResponse)
                    })
                } else {
                    ViewUtility.showAlertWithAction(title: "Error", message: holidaysResponse?.message ?? "", viewController: self, completion: { _ in
                        self.stopActivityIndicatorSpinner()
                    })
                }
            })
            
        case 1:
            self.startActivityIndicatorSpinner()
            self.publicHolidaysUseCase?.getHolidays(completion: { holidays, holidaysResponse in
                guard let success = holidaysResponse?.success else {
                    self.stopActivityIndicatorSpinner()
                    return
                }
                if success {
                    self.holidays = holidays
                    self.userUseCase?.readUser(completion: { user in
                        self.requestUseCase?.getAllByTeam(from: date, teamId: user?.teamId ?? -1, completion: { requestResponse in
                            self.handle(requestResponse)
                        })
                    })
                } else {
                    ViewUtility.showAlertWithAction(title: "Error", message: holidaysResponse?.message ?? "", viewController: self, completion: { _ in
                        self.stopActivityIndicatorSpinner()
                    })
                }
            })
            
        default:
            self.startActivityIndicatorSpinner()
            self.publicHolidaysUseCase?.getHolidays(completion: { holidays, holidaysResponse in
                guard let success = holidaysResponse?.success else {
                    self.stopActivityIndicatorSpinner()
                    return
                }
                if success {
                    self.holidays = holidays
                    if let searchableId = self.searchableId {
                        self.requestUseCase?.getAllBy(id: searchableId) { requestResponse in
                            self.handle(requestResponse)
                        }
                    } else {
                        self.requestUseCase?.getAllForCalendar { requestResponse in
                            self.handle(requestResponse)
                        }
                    }
                } else {
                    ViewUtility.showAlertWithAction(title: "Error", message: holidaysResponse?.message ?? "", viewController: self, completion: { _ in
                        self.stopActivityIndicatorSpinner()
                    })
                }
            })
        }
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = segmentedControl.selectedSegmentIndex == 2 ? searchController :  nil
        }
    }
    
    func handle(_ requestResponse: GenericResponse<[Date: [Request]]>?) {
        guard let success = requestResponse?.success else {
            self.stopActivityIndicatorSpinner()
            return
        }
        if success {
            self.items = requestResponse?.item ?? [:]
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
        if holidays.keys.contains(date) {
            
            guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: PublicHolidayTableViewCell.self), for: indexPath)
                as? PublicHolidayTableViewCell else {
                    return JTAppleCell()
            }
            
            cell.cellState = cellState
            cell.setCell(processor: processor)
            return cell
        } else {
            if segmentedControl.selectedSegmentIndex == 2 {
                guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self),
                                                              for: indexPath)
                    as? CalendarCellCollectionViewCell else {
                        return JTAppleCell()
                }
                
                cell.cellState = cellState
                let requests: [Request] = items[date] ?? []
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
                let requests: [Request] = items[date] ?? []
                cell.requests = requests
                cell.setCell(processor: processor)
                return cell
            }
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
    
}

extension TeamCalendarViewController: RequestDetailsDialogProtocol {
    func dismissDialog() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
            self.refreshUI(date: self.lastDateInMonth)
        }
    }
}
