//
//  SelectLeaveTypeViewController.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class SelectRequestParamsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items: [SectionData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SelectRequestParamsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        
        guard let items = items,
              let title = items[indexPath.section].cells?[indexPath.row].title else {
            return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell.textLabel?.text = title
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
}
