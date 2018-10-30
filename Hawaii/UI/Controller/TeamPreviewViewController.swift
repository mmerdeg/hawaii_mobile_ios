//
//  TeamPreviewViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class TeamPreviewViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: RequestDetailsDialogProtocol?
    
    var requests: [Int: [Request]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: String(describing: TeamPreviewTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: TeamPreviewTableViewCell.self))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.primaryColor
    }
    
}
extension TeamPreviewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        tableView.separatorColor = UIColor.primaryColor
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TeamPreviewTableViewCell.self), for: indexPath)
            as? TeamPreviewTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.request = Array(requests ?? [:])[indexPath.section].value[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = UIColor.primaryTextColor
        label.text = String(describing: Array(requests ?? [:])[section].key)
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(requests ?? [:])[section].value.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let requests = requests else {
            return 0
        }
        return requests.count
    }
}
