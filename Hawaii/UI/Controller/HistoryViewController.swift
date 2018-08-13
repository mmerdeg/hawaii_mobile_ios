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
    
    var customView: UIView = UIView()
    
    var requestUseCase: RequestUseCaseProtocol!
    
    var requests: [Request] = []
    
    let searchRequestsSegue = "searchRequests"
    
    lazy var searchItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(searchRequest))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: String(describing: RequestDetailTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: RequestDetailTableViewCell.self))
        tableView.tableFooterView = UIView()
        customView.frame = self.view.frame
        self.navigationItem.rightBarButtonItem = searchItem
        fillCalendar()
    }
    
    func fillCalendar() {
        requestUseCase.getAll { request in
            self.requests = request
            self.tableView.reloadData()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == searchRequestsSegue {
            guard let controller = segue.destination as? SearchRequestsViewController else {
                return
            }
            controller.delegate = self
        }
    }
    
    @objc func searchRequest() {
        self.navigationController?.view.addSubview(customView)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.customView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                self.navigationController?.view.bringSubview(toFront: self.customView)
            })
        }
        self.performSegue(withIdentifier: searchRequestsSegue, sender: nil)
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

extension HistoryViewController: SearchDialogProtocol {
    func didSearch(from: Date, toDate: Date) {
        requestUseCase.getAllByDate(from: from, toDate: toDate) { requests in
            self.requests = requests
            self.tableView.reloadData()
        }
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }
    
    func dismissDialog() {
        DispatchQueue.main.async {
            self.customView.removeFromSuperview()
        }
    }
}
