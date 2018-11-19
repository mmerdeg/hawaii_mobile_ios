//
//  TeamsMenagementViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class TeamsMenagementViewController: BaseViewController {

    @IBOutlet var tableView: UITableView!
    
    var searchableId: Int?
    
    var teamUseCase: TeamUseCaseProtocol?
    
    var teams: [Team]?
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: UserPreviewTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: UserPreviewTableViewCell.self))
        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.darkPrimaryColor
        self.view.backgroundColor = UIColor.darkPrimaryColor
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
    }
    
    func fillData() {
        startActivityIndicatorSpinner()
        self.teamUseCase?.getTeams(completion: { response in
            guard let success = response?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.stopActivityIndicatorSpinner()
                self.handleResponseFaliure(message: response?.message)
                return
            }
            self.teams = response?.item
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.stopActivityIndicatorSpinner()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserPreviewTableViewCell.self),
                                                       for: indexPath)
            as? UserPreviewTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        //cell.user = users[indexPath.row]
        return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
