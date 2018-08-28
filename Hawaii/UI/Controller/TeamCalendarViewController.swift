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
    
    let formatter = DateFormatter()
    var requestUseCase: RequestUseCaseProtocol?
    var items: [Request] = []
    var customView: UIView = UIView()
    
    let processor = SVGProcessor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.textColor = UIColor.primaryTextColor
        nextButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        previousButton.setTitleColor(UIColor.primaryTextColor, for: .normal)
        customView.frame = self.view.frame
        let nib = UINib(nibName: String(describing: CalendarCellCollectionViewCell.self), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: String(describing: CalendarCellCollectionViewCell.self))
        let nib2 = UINib(nibName: String(describing: TeamCalendarCollectionViewCell.self), bundle: nil)
        collectionView?.register(nib2, forCellWithReuseIdentifier: String(describing: TeamCalendarCollectionViewCell.self))
        collectionView.calendarDataSource = self
        collectionView.calendarDelegate = self
        
        collectionView.scrollingMode = .stopAtEachCalendarFrame
        setupCalendarView()
        fillCalendar()
        collectionView.scrollToDate(Date(), animateScroll: false)
        initFilterHeader()
    }
    
    func initFilterHeader() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.accentColor
        segmentedControl.backgroundColor = UIColor.black
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 1:
            startActivityIndicatorSpinner()
            requestUseCase?.getAllByTeam(from: Date(), teamId: -1, completion: { requests in
                self.items = requests
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.stopActivityIndicatorSpinner()
                }
            })
        case 2:
            startActivityIndicatorSpinner()
            requestUseCase?.getAllByTeam(from: Date(), teamId: -1, completion: { requests in
                self.items = requests
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.stopActivityIndicatorSpinner()
                }
            })
        default:
            startActivityIndicatorSpinner()
            requestUseCase?.getAllByTeam(from: Date(), teamId: -1, completion: { requests in
                self.items = requests
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.stopActivityIndicatorSpinner()
                }
            })
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    func showDetails(_ requests: [Request]) {
        self.navigationController?.view.addSubview(customView)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.customView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.navigationController?.view.bringSubview(toFront: self.customView)
            })
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
        startActivityIndicatorSpinner()
        requestUseCase?.getAllByTeam(from: Date(), teamId: -1, completion: { requests in
            self.items = requests
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
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
}

extension TeamCalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = Calendar.current.timeZone
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
            for day in days where calendar.compare(day.date ?? Date(), to: cellState.date, toGranularity: .day) == .orderedSame {
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
                for day in days where calendar.compare(day.date ?? Date(), to: cellState.date, toGranularity: .day) == .orderedSame {
                    let tempRequest = Request(request: item, days: [day])
                    requests.append(tempRequest)
                }
            }
            cell.requests = requests
            cell.setCell(processor: processor)
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
           // addRequest(date)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCellCollectionViewCell else {
            return
        }
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: CalendarCellCollectionViewCell, cellState: CellState, date: Date) {
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView()
    }
    
}
