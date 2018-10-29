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
    
    let showDatePickerSegue = "showDatePicker"
    
    var items: [CellData] = []
    
    var typeData: [String: [Absence]]?
    
    var requestType: AbsenceType?
    
    var tableDataProviderUseCase: TableDataProviderUseCaseProtocol?
    
    var selectedDuration = ""
    
    var startDate: Date?
    
    var endDate: Date?
    
    var dateItems: [ExpandableData] = []
    
    var isMultipleDaysSelected = false
    
    weak var delegate: SelectAbsenceProtocol?
    
    var selectedAbsence: Absence? {
        didSet {
            if let selectedAbsence = selectedAbsence {
                delegate?.didSelect(absence: selectedAbsence)
            }
        }
    }
    
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
        
        switch requestType {
        case .sick:
            tableDataProviderUseCase?.getSicknessData(completion: { data, sicknessTypeData, sicknessResponse in
                self.handleTableDataResponse(data: data, typeData: sicknessTypeData, response: sicknessResponse)
            })
        case .bonus:
            tableDataProviderUseCase?.getBonusData(completion: { data, bonusTypeData, bonusResponse in
                self.handleTableDataResponse(data: data, typeData: bonusTypeData, response: bonusResponse)
            })
        default:
            tableDataProviderUseCase?.getLeaveData(completion: { data, leaveTypeData, leaveResponse in
                self.handleTableDataResponse(data: data, typeData: leaveTypeData, response: leaveResponse)
            })
        }
    }
    
    func handleTableDataResponse(data: [CellData], typeData: [String: [Absence]], response: GenericResponse<[Absence]>) {
        
        self.stopActivityIndicatorSpinner()
        
        guard let success = response.success else {
            return
        }
        if success {
            self.tableDataProviderUseCase?.getExpandableData(forDate: self.startDate ?? Date(), completion: { items in
                self.dateItems = items
                self.setItems(data: data)
                self.typeData = typeData
                self.selectedAbsence = response.item?.first
            })
        } else {
            ViewUtility.showAlertWithAction(title: ViewConstants.errorDialogTitle, message: response.message ?? "",
                                            viewController: self, completion: { _ in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func setItems(data: [CellData]) {
        items = data
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let durationTitle = "Duration"
        let leaveTitle = "Type of leave"
        let sicknessTitle = "Type of sickness"
        
        if segue.identifier == selectParametersSegue {
            
            guard let controller = segue.destination as? SelectRequestParamsViewController,
                let data = sender as? [SectionData] else {
                    return
            }
            controller.items = data
            if data[0].name == nil {
                controller.title = durationTitle
            } else if requestType == .deducted {
                controller.title = leaveTitle
            } else {
                controller.title = sicknessTitle
            }
            controller.delegate = self
            
        } else if segue.identifier == selectAbsenceSegue {
            
            guard let controller = segue.destination as? SelectAbsenceViewController else {
                return
            }
            if requestType == .deducted {
                controller.title = leaveTitle
            } else {
                controller.title = sicknessTitle
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
        switch section {
        case 0:
            return dateItems.count
        case 1:
            return items.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.textColor = UIColor.primaryTextColor
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.transparentColor
        
        switch indexPath.section {
        case 0:
            let formatter = DisplayedDateFormatter()
            cell.textLabel?.text = dateItems[indexPath.row].title
            cell.detailTextLabel?.text = formatter.string(from: startDate ?? Date())
        case 1:
            cell.textLabel?.text = self.items[indexPath.row].title
            cell.detailTextLabel?.text = self.items[indexPath.row].description
        default:
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
        
        let datePickerSelected = indexPath.section == 0
        let absencePickerSelected = indexPath.row == 0
        let isBonusRequest = items.count != 2
        
        if datePickerSelected {
            self.performSegue(withIdentifier: showDatePickerSegue,
                              sender: (indexPath.row == 1 ? true : false, startDate, endDate))
            return
        }
        if absencePickerSelected && !isBonusRequest {
            self.performSegue(withIdentifier: self.selectAbsenceSegue, sender: nil)
            return
        }
        if isBonusRequest {
            tableDataProviderUseCase?.getBonusDaysDurationData(completion: { data in
                self.selectRequestParameters(data)
            })
            return
        }
        if isMultipleDaysSelected {
            tableDataProviderUseCase?.getMultipleDaysDurationData(completion: { data in
                self.selectRequestParameters(data)
            })
            return
        }
        tableDataProviderUseCase?.getDurationData(completion: { data in
            self.selectRequestParameters(data)
        })
    }
    
    func selectRequestParameters(_ data: [SectionData]? = nil) {
        performSegue(withIdentifier: self.selectParametersSegue, sender: data)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
}

extension RequestTableViewController: SelectRequestParamProtocol {
    
    func didSelect(requestParam: String, requestParamType: String, index: Int) {
        selectedDuration = requestParam
        let isNotBonusRequest = items.count == 2
        tableView.cellForRow(at: IndexPath(row: isNotBonusRequest ? 1 : 0, section: 1))?.detailTextLabel?.text = requestParam
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
        
        guard let startDateCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)),
            let endDateCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) else {
                return
        }
        let formatter = DisplayedDateFormatter()
        startDateCell.detailTextLabel?.text = formatter.string(from: startDate ?? Date())
        endDateCell.detailTextLabel?.text = formatter.string(from: endDate ?? startDate ?? Date())
    }
}
