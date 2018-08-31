//
//  DatePickerViewController.swift
//  Hawaii
//
//  Created by Server on 7/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

//class DatePickerViewController: UIViewController {
//
//    @IBOutlet weak var startDatePicker: WhiteUIDatePicker!
//
//    @IBOutlet weak var endDatePicker: WhiteUIDatePicker!
//
//    @IBOutlet weak var startDateLabel: UILabel!
//
//    @IBOutlet weak var endDateLabel: UILabel!
//
//    var selectedDate: Date?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        startDatePicker.date = selectedDate ?? Date()
//        startDateLabel.textColor = UIColor.secondaryTextColor
//        endDateLabel.textColor = UIColor.secondaryTextColor
//        endDatePicker.date = selectedDate ?? Date()
//    }
//}

class DatePickerViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SelectAbsenceProtocol?
    
    var tableDataProviderUseCase: TableDataProviderUseCaseProtocol?
    
    @IBOutlet weak var startDatePicker: WhiteUIDatePicker!
    
    @IBOutlet weak var endDatePicker: WhiteUIDatePicker!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    var selectedDate: Date?
    
    var items: [ExpandableData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
                cell.textLabel?.text = "Start date"
                cell.detailTextLabel?.text = String(describing: selectedDate)
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
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(items.filter { $0.expanded == true }.count)
        return items.filter { $0.expanded == true }.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let expanded = items[indexPath.row + 1].expanded else {
            return
        }
        items[indexPath.row + 1] = ExpandableData(expandableData: items[indexPath.row + 1], expanded: !expanded)
        print(items[indexPath.row + 1].title)
        if items[indexPath.row + 1].expanded ?? false {
            tableView.insertRows(at: [IndexPath(item: indexPath.row + 1, section: 0)], with: .fade)
        } else {
            tableView.deleteRows(at: [IndexPath(item: indexPath.row + 1, section: 0)], with: .fade)
        }
    }
}

