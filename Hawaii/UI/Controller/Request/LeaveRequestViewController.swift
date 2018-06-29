//
//  LeaveRequestViewController.swift
//  Hawaii
//
//  Created by Server on 6/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class LeaveRequestViewController: BaseViewController {

    @IBOutlet weak var progressBar: YLProgressBar!
    
    @IBOutlet weak var tableView: UITableView!
   
    let selectParametersSegue = "selectParameters"
    
    var items: [CellData] = []
    
    var tableDataProviderUseCase: TableDataProviderUseCaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.setProgress(0.5, animated: true)
        setupTableView()
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableDataProviderUseCase?.getLeaveData(completion: { data in
            self.items = data
            self.tableView.reloadData()
        })
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

extension LeaveRequestViewController: UITableViewDelegate, UITableViewDataSource {
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
            tableDataProviderUseCase?.getLeaveTypeData(completion: { data in
                self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
            })
            
        } else {
            tableDataProviderUseCase?.getDurationData(completion: { data in
                self.performSegue(withIdentifier: self.selectParametersSegue, sender: data)
            })
        }
    }
}
