//
//  PublicHolidaysMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class PublicHolidaysManagementViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchableId: Int?
    
    var publicHolidayUseCase: PublicHolidayUseCaseProtocol?
    
    var holidays: [Int: [PublicHoliday]]?
    
    let managePublicHolidaySegue = "managePublicHoliday"
    
    lazy var addBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    lazy var editBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(showEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    lazy var doneBarItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(showEditing))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: HolidayTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: HolidayTableViewCell.self))
        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.darkPrimaryColor
        self.view.backgroundColor = UIColor.darkPrimaryColor
        self.navigationItem.rightBarButtonItem = addBarItem
        self.navigationItem.leftBarButtonItem = editBarItem
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == managePublicHolidaySegue {
            if let holiday = sender as? PublicHoliday {
                guard let controller = segue.destination as? PublicHolidayManagementViewController else {
                    return
                }
                controller.holiday = holiday
            }
        }
    }
    
    @objc func addItem() {
        self.performSegue(withIdentifier: self.managePublicHolidaySegue, sender: nil)
    }
    
    @objc func showEditing() {
        if self.tableView.isEditing == true {
            self.tableView.isEditing = false
            self.navigationItem.rightBarButtonItem = addBarItem
            self.navigationItem.leftBarButtonItem = editBarItem
        } else {
            self.tableView.isEditing = true
            self.navigationItem.rightBarButtonItem = doneBarItem
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
}

extension PublicHolidaysManagementViewController: UITableViewDataSource, UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(describing: Array(self.holidays ?? [:])[section].key)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(holidays ?? [:])[section].value.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return holidays?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: managePublicHolidaySegue, sender: Array(holidays ?? [:])[indexPath.section].value[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let confirmationAlertTitle = LocalizedKeys.General.confirm.localized()
            let approveAlertMessage = LocalizedKeys.General.deleteMessage.localized()
            
            AlertPresenter.showAlertWithAction(title: confirmationAlertTitle, message: approveAlertMessage, cancelable: true,
                                               viewController: self) { confirmed in
                                                if confirmed {
                                                    let selectedHoliday = Array(self.holidays ?? [:])[indexPath.section].value[indexPath.row]
                                                    self.publicHolidayUseCase?.delete(holiday: selectedHoliday, completion: { response in
                                                        guard let success = response?.success else {
                                                            self.stopActivityIndicatorSpinner()
                                                            return
                                                        }
                                                        if !success {
                                                            self.stopActivityIndicatorSpinner()
                                                            self.handleResponseFaliure(message: response?.message)
                                                            return
                                                        }
                                                        
                                                    })
                                                    #warning("Dont forget to bring back")
                                                    var holidaysInSourceSection = Array(self.holidays ?? [:])[indexPath.section].value
                                                    let sourceSection = Array(self.holidays ?? [:])[indexPath.section].key
                                                    holidaysInSourceSection.remove(at: indexPath.row)
                                                    self.holidays?[sourceSection] = holidaysInSourceSection
                                                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                                                }
            }
        }
    }
}
