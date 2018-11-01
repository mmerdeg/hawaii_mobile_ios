import UIKit

protocol RequestCancelationProtocol: class {
    func requestCanceled(request: Request?, cell: RequestDetailTableViewCell)
}

class RequestDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var requestDuration: UILabel!
    
    @IBOutlet weak var requestDates: UILabel!
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var requestImageFrame: UIView!
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var requestStatus: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var requestReason: UILabel!
    
    @IBOutlet weak var requestNotes: UILabel!
    
    var isCancelHidden = false
    
    weak var requestCancelationDelegate: RequestCancelationProtocol?
    
    var request: Request? {
        didSet {
            guard let notes = request?.reason,
                let imageUrl = request?.absence?.iconUrl,
                let duration = request?.days?.first?.duration?.description,
                let startDate = request?.days?.first?.date,
                let reason = request?.absence?.name,
                let endDate = request?.days?.last?.date,
                let status = request?.requestStatus,
                let absenceType = request?.absence?.absenceType,
                var color = request?.requestStatus?.backgoundColor else {
                    return
            }
            
            if absenceType == AbsenceType.sick.rawValue {
                color = AbsenceType.sick.backgoundColor ?? UIColor.sickColor
            }
            requestNotes.text = notes
            requestDuration.text = String(duration)
            requestStatus.text = status.description
            requestReason.text = reason
            
            let formatter = DisplayedDateFormatter()
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            requestDates.text = start == end ? start : start + " - " + end
      
            cardView.backgroundColor = UIColor.lightPrimaryColor
            date.text = DateStringConverter.convertDateString(dateString: request?.submissionTime ?? "",
                                          fromFormat: ViewConstants.dateSourceFormat,
                                          toFormat: formatter.format)
            
            requestImage.kf.setImage(with: URL(string: ViewConstants.baseUrl + "/" + imageUrl))
            requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.primaryColor
            requestImage.backgroundColor = color
            requestImage.layer.cornerRadius = requestImage.frame.width / 2
            requestImage.layer.masksToBounds = true
            requestImageFrame.backgroundColor = color
            requestImageFrame.layer.cornerRadius = requestImageFrame.frame.width / 2
            requestImageFrame.layer.masksToBounds = true
            
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.transparentColor.cgColor
            
            cancelButton.isHidden = isCancelHidden || (status != .pending && status != .approved)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.primaryColor
        selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    @IBAction func onCancel(_ sender: Any) {
        requestCancelationDelegate?.requestCanceled(request: request, cell: self)
    }
}
