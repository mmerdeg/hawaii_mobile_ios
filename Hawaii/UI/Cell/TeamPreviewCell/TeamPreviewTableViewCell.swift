import UIKit

class TeamPreviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var requestImageFrame: UIView!
    
    @IBOutlet weak var requestOwner: UILabel!
    
    @IBOutlet weak var requestDuration: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    weak var requestCancelationDelegate: RequestCancelationProtocol?
    
    var request: Request? {
        didSet {
            guard let notes = request?.user?.fullName,
                let imageUrl = request?.absence?.iconUrl,
                let startDate = request?.days?.first?.date,
                let endDate = request?.days?.last?.date,
                let absenceType = request?.absence?.absenceType,
                var color = request?.requestStatus?.backgoundColor else {
                    return
            }
            
            if absenceType == AbsenceType.sick.rawValue {
                color = UIColor.sickColor
            }
            self.backgroundColor = UIColor.primaryColor
            requestOwner.text = notes
            requestOwner.textColor = UIColor.primaryTextColor
            
            let dateFormatter = DisplayedDateFormatter()
            let start = dateFormatter.string(from: startDate)
            let end = dateFormatter.string(from: endDate)

            requestDuration.text = start == end ? start : start + " - " + end
            requestDuration.textColor = UIColor.primaryTextColor

            cardView.backgroundColor = UIColor.lightPrimaryColor
            
            requestImage.kf.setImage(with: URL(string: ViewConstants.baseUrl + "/" + imageUrl))
            requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.statusIconColor
            requestImage.layer.cornerRadius = requestImage.frame.height / 2
            requestImage.layer.masksToBounds = true
            requestImage.backgroundColor = color
            requestImageFrame.layer.cornerRadius = requestImageFrame.frame.height / 2
            requestImageFrame.layer.masksToBounds = true
            requestImageFrame.backgroundColor = color
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.transparentColor.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCellSelectionStyle.none
    }
}
