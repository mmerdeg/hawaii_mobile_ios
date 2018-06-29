//
//  HistoryViewController.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class HistoryViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var requestUseCase: RequestUseCaseProtocol!
    
    var requests: [Request] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: String(describing: RequestDetailTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: RequestDetailTableViewCell.self))
        tableView.tableFooterView = UIView()
        fillCalendar()
    }
    
    func fillCalendar() {
        requestUseCase.getAll { request in
            self.requests = request
            self.tableView.reloadData()
            
        }
    }
    
}
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RequestDetailTableViewCell.self), for: indexPath)
            as? RequestDetailTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell.request = requests[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
}
