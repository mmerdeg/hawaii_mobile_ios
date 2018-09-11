//
//  RequestTableViewController.swift
//  Hawaii
//
//  Created by Server on 7/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class RequestTableViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let selectParametersSegue = "selectParameters"
    let selectAbsenceSegue = "selectAbsence"
    
    var items: [CellData] = []
    
    var leaveTypeData: [String: [Absence]]?
    
    var requestType: AbsenceType?
    
    var tableDataProviderUseCase: TableDataProviderUseCaseProtocol?
    
    var selectedTypeIndex = 0
    
    var selectedDurationIndex = 0
    var selectedAbsence: Absence?
    
    var startDate: Date?
    
    var endDate: Date?
    
    var dateItems: [ExpandableData] = []
    
    let showDatePickerSegue = "showDatePicker"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        endDate = startDate
        guard let requestType = requestType else {
            return
        }
        
        if requestType == .deducted {
            tableDataProviderUseCase?.getLeaveData(completion: { data, leaveTypeData, absence in
                self.tableDataProviderUseCase?.getExpandableData(forDate: self.startDate ?? Date(), completion: { items in
                    self.dateItems = items
                    self.setItems(data: data)
                    self.leaveTypeData = leaveTypeData
                    self.selectedAbsence = absence
                })
            })
        } else {
            tableDataProviderUseCase?.getSicknessData(completion: { data in
                self.tableDataProviderUseCase?.getExpandableData(forDate: self.startDate ?? Date(), completion: { items in
                    self.dateItems = items
                    self.setItems(data: data)
                })
            })
        }
    }
    
    func setItems(data: [CellData]) {
        items = data
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == selectParametersSegue {
            guard let controller = segue.destination as? SelectRequestParamsViewController,
                let data = sender as? [SectionData] else {
                    return
            }
            controller.items = data
            if data[0].name == nil {
                controller.title = "Duration"
            } else if requestType == .deducted {
                controller.title = "Type of leave"
            } else {
                controller.title = "Type of sickness"
            }
            controller.delegate = self
        } else if segue.identifier == selectAbsenceSegue {
            guard let controller = segue.destination as? SelectAbsenceViewController else {
                return
            }
            if requestType == .deducted {
                controller.title = "Type of leave"
            } else {
                controller.title = "Type of sickness"
            }
            controller.items = leaveTypeData
            controller.delegate = self
        } else if segue.identifier == showDatePickerSegue {
            guard let controller = segue.destination as? CustomDatePickerTableViewController,
                let params = sender as? (Bool, [Date]) else {
                    return
            }
            controller.items = params.1
            controller.isFirstSelected = params.0
            controller.delegate = self
        }
    }
    
    func getDurationSelection() -> DurationType {
        guard let durationType = DurationType(durationType: selectedDurationIndex) else {
            return DurationType.fullday
        }
        return durationType
    }
}

extension RequestTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.textColor = UIColor.primaryTextColor
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.transparentColor
        if indexPath.section == 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.dateFormat
            cell.textLabel?.text = dateItems[indexPath.row].title
            cell.detailTextLabel?.text = formatter.string(from: startDate ?? Date())
        } else {
            cell.textLabel?.text = self.items[indexPath.row].title
            cell.detailTextLabel?.text = self.items[indexPath.row].description
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: showDatePickerSegue,
                              sender: (indexPath.row == 1 ? true: false, [startDate]))
        } else {
            if indexPath.row == 0 {
                if requestType == .deducted {
                        self.performSegue(withIdentifier: self.selectAbsenceSegue, sender: nil)
                } else {
                    tableDataProviderUseCase?.getSicknessTypeData(completion: { data in
                        self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
                    })
                }
            } else {
                tableDataProviderUseCase?.getDurationData(completion: { data in
                    self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
                })
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension RequestTableViewController: SelectRequestParamProtocol {
    
    func didSelect(requestParam: String, requestParamType: String, index: Int) {
        if requestParamType == "Duration" {
            selectedDurationIndex = index
            tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text = requestParam
        } else {
            selectedTypeIndex = index
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = requestParam
        }
    }
}
extension RequestTableViewController: SelectAbsenceProtocol {
    func didSelect(absence: Absence) {
        tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = absence.name
        selectedAbsence = absence
    }
}

extension RequestTableViewController: DatePickerProtocol {
    func selectedDate(_ dates: [Date]) {
        if dates.count == 1 {
            guard let startDate = dates.first else {
                return
            }
            self.startDate = startDate
            self.endDate = startDate
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.dateFormat
            guard let startDateCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)),
                  let endDateCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) else {
                    return
            }
            startDateCell.detailTextLabel?.text = formatter.string(from: startDate)
            endDateCell.detailTextLabel?.text = formatter.string(from: startDate)
            
        } else if dates.count > 2 {
            guard let endDate = dates.last else {
                return
            }
            self.endDate = endDate
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.dateFormat
            guard let prevousCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) else {
                return
            }
            prevousCell.detailTextLabel?.text = formatter.string(from: endDate)
        }
    }
    
}

