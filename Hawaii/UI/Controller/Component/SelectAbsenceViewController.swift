//
//  SelectAbsenceViewController.swift
//  Hawaii
//
//  Created by Server on 8/10/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol SelectAbsenceProtocol: class {
    func didSelect(absence: Absence)
}

class SelectAbsenceViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SelectAbsenceProtocol?
    
    var tableDataProviderUseCase: TableDataProviderUseCaseProtocol?
    
    var items: [String: [Absence]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SelectAbsenceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        
        guard let items = items,
            let title = Array(items)[indexPath.section].value[indexPath.row].name else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell.textLabel?.text = title
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.primaryTextColor
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(items ?? [:])[section].key
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(items ?? [:])[section].value.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let items = items else {
            return 0
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(absence: Array(items ?? [:])[indexPath.section].value[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}
