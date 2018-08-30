//
//  TeamPreviewViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

var requests: [Request]?

class TeamPreviewViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: RequestDetailsDialogProtocol?
    var requests: [Request] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: String(describing: TeamPreviewTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: TeamPreviewTableViewCell.self))
        tableView.tableFooterView = UIView()
    }
    
}
extension TeamPreviewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TeamPreviewTableViewCell.self), for: indexPath)
            as? TeamPreviewTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell.request = requests[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
}
