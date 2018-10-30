//
//  SearchUsersBaseViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 10/10/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol SearchUserSelectedProtocol: class {
    func didSelect(user: User)
}

class SearchUsersBaseViewController: BaseViewController, SearchUserProtocol {
    
    var resultsController: SearchUsersTableViewController?
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    var userUseCase: UserUseCaseProtocol?
    
    var searchController: UISearchController?
    
    var pendingRequestWorkItem: DispatchWorkItem?
    
    weak var delegate: SearchUserSelectedProtocol?

    var users: [User] = []
    
    var page = 0
    
    var numberOfItems = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = "Employees"
        
        setUpSearch()
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        }
        self.navigationItem.title = title
    }
    
    func loadMoreClicked(completion: @escaping () -> Void) {
        getUsers(parameter: searchController?.searchBar.text ?? "", page: page, numberOfItems: numberOfItems) {
            completion()
        }
    }
    
    func didSelect(user: User) {
        delegate?.didSelect(user: user)
        self.navigationController?.popViewController(animated: true)
        self.searchController?.dismiss(animated: true, completion: nil)
    }
    
    func setUpSearch() {
        
        let teamCalendarStoryboardName = "TeamCalendar"
        
        let storyboard = UIStoryboard(name: teamCalendarStoryboardName, bundle: nil)
        guard let searchUsersTableViewController = storyboard.instantiateViewController(withIdentifier:
                                                     String(describing: SearchUsersTableViewController.self))
                                                        as? SearchUsersTableViewController else {
            return
        }
        searchUsersTableViewController.delegate = self
        resultsController = searchUsersTableViewController

        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.searchBar.keyboardAppearance = .dark
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.tintColor = UIColor.white
        searchController?.searchBar.barTintColor = UIColor.white
        searchController?.searchBar.barStyle = .black
        self.definesPresentationContext = true
    }
    
    func getUsers(parameter: String, page: Int, numberOfItems: Int, completion: @escaping () -> Void) {
        userUseCase?.getUsersByParameter(parameter: parameter, page: page, numberOfItems: numberOfItems, completion: { response in
            guard let success = response.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.handleResponseFaliure(message: response.message)
                return
            }
            guard let users = response.users,
                  let usersMax = response.maxUsers else {
                    return
            }
            if !users.isEmpty {
                if self.page == 0 {
                    self.users = []
                }
                self.page += 1
                for user in users {
                    self.users.append(user)
                }
            }
            self.userDetailsUseCase?.setLoadMore(self.users.count < usersMax)
            self.resultsController?.users = self.users
            self.resultsController?.tableView.reloadData()
            completion()
        })
    }
    
}

extension SearchUsersBaseViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        pendingRequestWorkItem?.cancel()
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            self?.performSearch()
        }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: requestWorkItem)
    }
    
    @objc func performSearch() {
        self.users = []
        self.page = 0
        getUsers(parameter: searchController?.searchBar.text ?? "", page: 0, numberOfItems: numberOfItems) {
        }
    }
}
