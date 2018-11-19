//
//  PublicHolidaysMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class PublicHolidaysMenagementViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchableId: Int?
    
    var publicHolidayUseCase: PublicHolidayUseCaseProtocol?
    
    var holidays: [Date: [PublicHoliday]]?
    
    let menagePublicHolidaySegue = "menagePublicHoliday"
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: HolidayTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: HolidayTableViewCell.self))
        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.darkPrimaryColor
        self.view.backgroundColor = UIColor.darkPrimaryColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
        fillData()
    }
    
    func fillData() {
        startActivityIndicatorSpinner()
        publicHolidayUseCase?.getAllByYear { holidays, response in
            guard let success = response?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.handleResponseFaliure(message: response?.message)
                return
            }
            self.holidays = holidays
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
        }
    }
    
}

extension PublicHolidaysMenagementViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HolidayTableViewCell.self),
                                                       for: indexPath)
            as? HolidayTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.holiday = Array(holidays ?? [:])[indexPath.section].value[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = UIColor.primaryTextColor
        label.text = String(describing: 2018 + section)
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(holidays ?? [:])[section].value.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return holidays?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: menagePublicHolidaySegue, sender: Array(holidays ?? [:])[indexPath.section].value[indexPath.row])
    }
}
