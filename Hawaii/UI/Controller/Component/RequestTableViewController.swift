//
//  RequestTableViewController.swift
//  Hawaii
//
//  Created by Server on 7/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class RequestTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let selectParametersSegue = "selectParameters"
    
    var items: [CellData] = []
    
    var requestType: RequestType?
    
    var tableDataProviderUseCase: TableDataProviderUseCaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        guard let requestType = requestType else {
            return
        }
        
        if requestType == .vacation {
            tableDataProviderUseCase?.getLeaveData(completion: { data in
                self.setItems(data: data)
            })
        } else {
            tableDataProviderUseCase?.getSicknessData(completion: { data in
                self.setItems(data: data)
            })
        }
    }
    
    func setRequestType(type: RequestType) {
        requestType = type
        setupTableView()
    }
    
    func setItems(data: [CellData]) {
        items = data
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == selectParametersSegue {
            guard let controller = segue.destination as? SelectRequestParamsViewController,
                let data = sender as? [SectionData] else {
                    return
            }
            controller.items = data
        }
    }
}

extension RequestTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.items[indexPath.row].title
        cell.detailTextLabel?.text = self.items[indexPath.row].description
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.transparentColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if requestType == .vacation {
                tableDataProviderUseCase?.getLeaveTypeData(completion: { data in
                    self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
                })
            } else {
                tableDataProviderUseCase?.getSicknessTypeData(completion: { data in
                    self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
                })
            }
        } else {
            tableDataProviderUseCase?.getDurationData(completion: { data in
                self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
            })
        }
    }
    
}
