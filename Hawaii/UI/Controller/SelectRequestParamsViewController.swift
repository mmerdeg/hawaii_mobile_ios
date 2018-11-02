//
//  SelectLeaveTypeViewController.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol SelectRequestParamProtocol: class {
    func didSelect(requestParam: String, requestParamType: String, index: Int)
}

class SelectRequestParamsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SelectRequestParamProtocol?
    
    var items: [SectionData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SelectRequestParamsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        tableView.backgroundColor = UIColor.clear
        
        guard let items = items,
              let title = items[indexPath.section].cells?[indexPath.row].title else {
            return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.textLabel?.text = title
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.primaryTextColor
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightPrimaryColor
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let items = items else {
                return ""
        }
        return items[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = items else {
                return 0
        }
        return items[section].cells?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let items = items else {
                return 0
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let title = items?[indexPath.section].cells?[indexPath.row].title else {
            return
        }
        delegate?.didSelect(requestParam: title, requestParamType: self.title ?? "", index: indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
}
