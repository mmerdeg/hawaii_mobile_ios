//
//  DatePickerViewController.swift
//  Hawaii
//
//  Created by Server on 7/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

class DatePickerViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SelectAbsenceProtocol?
    
    var tableDataProviderUseCase: TableDataProviderUseCaseProtocol?
    
    var startDate: Date?
    
    var endDate: Date?
    
    var selectedDate: Date?
    
    var items: [ExpandableData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        startDate = selectedDate
        endDate = selectedDate
        let nib = UINib(nibName: String(describing: DatePickerTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: DatePickerTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.primaryColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableDataProviderUseCase?.getExpandableData(forDate: selectedDate ?? Date(), completion: { items in
            self.items = items
            self.tableView.reloadData()
        })
    }
}

extension DatePickerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = items.filter { $0.expanded == true }
        if list[indexPath.row].id == 0 {
                let formatter = DateFormatter()
                formatter.dateFormat = Constants.dateFormat
            
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
            
                cell.textLabel?.text = indexPath.row == 0 ?  "Start date": "End date"
                cell.detailTextLabel?.text = formatter.string(from: selectedDate ?? Date())
                cell.textLabel?.textColor = UIColor.primaryTextColor
                cell.selectionStyle = .none
                cell.accessoryType = .disclosureIndicator
                cell.backgroundColor = UIColor.transparentColor
                cell.tag = indexPath.row
                return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DatePickerTableViewCell.self), for: indexPath)
                as? DatePickerTableViewCell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell.tag = indexPath.row
            cell.datePicker.date = selectedDate ?? Date()
            cell.delegate = self
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.filter { $0.expanded == true }.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = items.filter { $0.expanded == true }[indexPath.row]
        let index = items.index(of: item) ?? 0
        items[index + 1] = ExpandableData(expandableData: items[index + 1], expanded: !(items[index + 1].expanded ?? false))
        if items[index + 1].expanded ?? false {
            tableView.insertRows(at: [IndexPath(item: indexPath.row + 1, section: 0)], with: .fade)
        } else {
            tableView.deleteRows(at: [IndexPath(item: indexPath.row + 1, section: 0)], with: .fade)
        }
    }
}

extension DatePickerViewController: DatePickerProtocol {
    func selectedDate(_ date: Date, cell: DatePickerTableViewCell) {
        if cell.tag == 1 {
            startDate = date
        } else {
            endDate = date
        }
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        guard let prevousCell = tableView.cellForRow(at: IndexPath(row: cell.tag - 1, section: 0)) else {
            return
        }
        prevousCell.detailTextLabel?.text = formatter.string(from: date)
    }
}
