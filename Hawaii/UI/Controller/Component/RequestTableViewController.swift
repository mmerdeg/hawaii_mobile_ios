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
    
    var typeData: [String: [Absence]]?
    
    var requestType: AbsenceType?
    
    var tableDataProviderUseCase: TableDataProviderUseCaseProtocol?
    
    //var selectedTypeIndex = 0
    
    var selectedDuration = ""
    var selectedAbsence: Absence? {
        didSet {
            if let selectedAbsence = selectedAbsence {
                delegate?.didSelect(absence: selectedAbsence)
            }
        }
    }
    
    var startDate: Date?
    
    var endDate: Date?
    
    var dateItems: [ExpandableData] = []
    
    var isMultipleDaysSelected = false
    
    weak var delegate: SelectAbsenceProtocol?
    
    let showDatePickerSegue = "showDatePicker"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.primaryColor
        endDate = startDate
        tableView.register(UINib(nibName: String(describing: InputTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: InputTableViewCell.self))
        guard let requestType = requestType else {
            return
        }
        
        if requestType == .deducted {
            tableDataProviderUseCase?.getLeaveData(completion: { data, leaveTypeData, response in
                guard let success = response.success else {
                    self.stopActivityIndicatorSpinner()
                    return
                }
                if success {
                    self.tableDataProviderUseCase?.getExpandableData(forDate: self.startDate ?? Date(), completion: { items in
                        self.dateItems = items
                        self.setItems(data: data)
                        self.typeData = leaveTypeData
                        self.selectedAbsence = response.item?.first
                        
                        self.stopActivityIndicatorSpinner()
                    })
                } else {
                    ViewUtility.showAlertWithAction(title: "Error", message: response.message ?? "", viewController: self, completion: { _ in
                        self.stopActivityIndicatorSpinner()
                    })
                }
            
            })
        } else if requestType == .sick {
            tableDataProviderUseCase?.getSicknessData(completion: { data, sicknessTypeData, response  in
                self.tableDataProviderUseCase?.getExpandableData(forDate: self.startDate ?? Date(), completion: { items in
                    self.dateItems = items
                    self.setItems(data: data)
                    self.typeData = sicknessTypeData
                    self.selectedAbsence = response.item?.first
                })
            })
        } else {
            tableDataProviderUseCase?.getBonusData(completion: { data, bonusTypeData, response   in
                self.tableDataProviderUseCase?.getExpandableData(forDate: self.startDate ?? Date(), completion: { items in
                    self.dateItems = items
                    self.setItems(data: data)
                    self.typeData = bonusTypeData
                    self.selectedAbsence = response.item?.first
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
            controller.items = typeData
            controller.delegate = self
        } else if segue.identifier == showDatePickerSegue {
            guard let controller = segue.destination as? CustomDatePickerTableViewController,
                let params = sender as? (Bool, Date, Date) else {
                    return
            }
            controller.isFirstSelected = params.0
            controller.startDate = params.1
            controller.endDate = params.2
            controller.delegate = self
        }
    }
    
    func getDurationSelection() -> DurationType {
        guard let durationType = DurationType(durationType: selectedDuration) else {
            return DurationType.fullday
        }
        return durationType
    }
}

extension RequestTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dateItems.count
        } else if section == 1 {
            return items.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath)
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
        } else if indexPath.section == 1 {
            cell.textLabel?.text = self.items[indexPath.row].title
            cell.detailTextLabel?.text = self.items[indexPath.row].description
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: InputTableViewCell.self), for: indexPath)
                as? InputTableViewCell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell.backgroundColor = UIColor.transparentColor
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: showDatePickerSegue,
                              sender: (indexPath.row == 1 ? true : false, startDate, endDate))
        } else {
            if indexPath.row == 0 && items.count == 2 {
                self.performSegue(withIdentifier: self.selectAbsenceSegue, sender: nil)
            } else {
                if isMultipleDaysSelected {
                    if requestType == .bonus {
                        tableDataProviderUseCase?.getBonusDaysDurationData(completion: { data in
                            self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
                        })
                    } else {
                        tableDataProviderUseCase?.getMultipleDaysDurationData(completion: { data in
                            self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
                        })
                    }
                } else {
                    if requestType == .bonus {
                        tableDataProviderUseCase?.getBonusDaysDurationData(completion: { data in
                            self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
                        })
                    } else {
                        tableDataProviderUseCase?.getDurationData(completion: { data in
                            self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
                        })
                    }
                }
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
}

extension RequestTableViewController: SelectRequestParamProtocol {
    
    func didSelect(requestParam: String, requestParamType: String, index: Int) {
        selectedDuration = requestParam
        if items.count == 2 {
            tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.detailTextLabel?.text = requestParam
        } else {
            tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.detailTextLabel?.text = requestParam
        }
    }
}
extension RequestTableViewController: SelectAbsenceProtocol {
    func didSelect(absence: Absence) {
        tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.detailTextLabel?.text = absence.name
        selectedAbsence = absence
    }
}

extension RequestTableViewController: DatePickerProtocol {
    
    func selectedDate(startDate: Date?, endDate: Date?, isMultipleDaysSelected: Bool) {
        self.startDate = startDate
        self.endDate = endDate ?? startDate
        self.isMultipleDaysSelected = isMultipleDaysSelected
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        guard let startDateCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)),
            let endDateCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) else {
                return
        }
        startDateCell.detailTextLabel?.text = formatter.string(from: startDate ?? Date())
        endDateCell.detailTextLabel?.text = formatter.string(from: endDate ?? startDate ?? Date())
    }
}
