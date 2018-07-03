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
            if data[0].name == nil {
                controller.title = "Duration"
            } else if requestType == .vacation {
                controller.title = "Type of leave"
            } else {
                controller.title = "Type of sickness"
            }
            controller.delegate = self
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
        cell.textLabel?.textColor = UIColor.accentColor
        cell.selectionStyle = .none
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

extension RequestTableViewController: SelectRequestParamProtocol {
    
    func didSelect(requestParam: String, requestParamType: String) {
        if requestParamType == "Duration" {
            tableView.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text = requestParam
        } else {
            tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = requestParam
        }
    }
    
}
