import UIKit

protocol SearchUserProtocol: class {
    
    func loadMoreClicked(completion: @escaping () -> Void)
    
    func didSelect(user: User)
}

class SearchUsersTableViewController: UITableViewController {
    
    var userDetailsUseCase: UserDetailsUseCase?
    
    var searchableId: Int?
    
    weak var delegate: SearchUserProtocol?
    
    var users: [User] = []
    
    override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: UserPreviewTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: UserPreviewTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: LoadMoreTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: LoadMoreTableViewCell.self))
        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.darkPrimaryColor
        self.view.backgroundColor = UIColor.darkPrimaryColor
        self.tableView.separatorStyle = .none
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = !users.isEmpty
        guard let loadMore = userDetailsUseCase?.getLoadMore() else {
            return users.count
        }
        return loadMore ? users.count + 1 : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        if indexPath.row == users.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier:
                String(describing: LoadMoreTableViewCell.self)) as? LoadMoreTableViewCell else {
                    let defaultCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
                    return defaultCell
            }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserPreviewTableViewCell.self),
                                                       for: indexPath)
            as? UserPreviewTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.user = users[indexPath.row]
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row != users.count {
            guard let cell = tableView.cellForRow(at: indexPath) as? UserPreviewTableViewCell,
                let user = cell.user else {
                    return
            }
            delegate?.didSelect(user: user)
            return
        }
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
    }
}
