import UIKit

class LoadMoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loadMore: UILabel!
    
    @IBOutlet weak var loadingMore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadMore.text = LocalizedKeys.Team.loadMore.localized()
        loadingMore.text = LocalizedKeys.Team.loadingMore.localized()
        loadMore.textColor = UIColor.primaryTextColor
        loadingMore.textColor = UIColor.primaryTextColor
        activityIndicator.color = UIColor.primaryTextColor
        loadingMore.isHidden = true
        self.backgroundColor = UIColor.darkPrimaryColor
    }
    
}
