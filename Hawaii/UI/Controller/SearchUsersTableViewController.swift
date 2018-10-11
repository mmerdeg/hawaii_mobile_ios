//
//  SearchUsersTableViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 10/10/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol SearchUserProtocol: class {
    func loadMoreClicked(completion: @escaping () -> Void)
    func didSelect(user: User)
}

class SearchUsersTableViewController: UITableViewController {
    
    var users: [User] = []
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    var searchableId: Int?
    
    weak var delegate: SearchUserProtocol?
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: UserPreviewTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: UserPreviewTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: LoadMoreTableViewCell.self), bundle: nil),
                                              forCellReuseIdentifier: String(describing: LoadMoreTableViewCell.self))
        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.darkPrimaryColor
        self.view.backgroundColor = UIColor.darkPrimaryColor
        self.tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.isEmpty {
            tableView.backgroundView?.isHidden = false
            return 0
        } else {
            guard let loadMore = userDetailsUseCase?.getLoadMore() else {
                return users.count
            }
            if loadMore {
                return users.count + 1
            } else {
                return users.count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == users.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier:
                String(describing: LoadMoreTableViewCell.self)) as? LoadMoreTableViewCell else {
                    let defaultCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
                    return defaultCell
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserPreviewTableViewCell.self),
                                                           for: indexPath)
                as? UserPreviewTableViewCell else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell.user = users[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == users.count {
            guard let loadMoreCell = tableView.cellForRow(at: indexPath) as? LoadMoreTableViewCell else {
                return
            }
            loadMoreCell.activityIndicator.startAnimating()
            loadMoreCell.loadMore.isHidden = true
            loadMoreCell.loadingMore.isHidden = false
            delegate?.loadMoreClicked(completion: {
                loadMoreCell.activityIndicator.stopAnimating()
                loadMoreCell.loadMore.isHidden = false
                loadMoreCell.loadingMore.isHidden = true
            })
        } else {
            guard let cell = tableView.cellForRow(at: indexPath) as? UserPreviewTableViewCell,
                  let user = cell.user else {
                return
            }
            delegate?.didSelect(user: user)
        }
    }
}

