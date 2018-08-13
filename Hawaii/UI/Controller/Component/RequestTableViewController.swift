//
//  RequestTableViewController.swift
//  Hawaii
//
//  Created by Server on 7/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class RequestTableViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        guard let requestType = requestType else {
            return
        }
        
        if requestType == .deducted {
            tableDataProviderUseCase?.getLeaveData(completion: { data, leaveTypeData in
                self.setItems(data: data)
                self.leaveTypeData = leaveTypeData
            })
        } else {
            tableDataProviderUseCase?.getSicknessData(completion: { data in
                self.setItems(data: data)
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
        }
    }
    
    func getTypeSelection() -> AbsenceSubType {
        guard let absenceType = AbsenceSubType(rawValue: selectedTypeIndex) else {
            return AbsenceSubType.vacation
        }
        return absenceType
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
        cell.textLabel?.text = self.items[indexPath.row].title
        cell.detailTextLabel?.text = self.items[indexPath.row].description
        cell.textLabel?.textColor = UIColor.primaryTextColor
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.transparentColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
