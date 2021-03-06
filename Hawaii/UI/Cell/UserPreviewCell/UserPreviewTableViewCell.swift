import UIKit

class UserPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fullName: UILabel!
    
    var user: User? {
        didSet {
            guard let userFullName = user?.fullName else {
                    return
            }
            profileImageView.kf.setImage(with: URL(string:
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTuYaHTYdunFCkaR7OwwMXMP_pwTxs_atlJRwBKekLVMl1iQVdag"))
            fullName.text = userFullName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.darkPrimaryColor
        profileImageView.backgroundColor = UIColor.darkPrimaryColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
    }

}
