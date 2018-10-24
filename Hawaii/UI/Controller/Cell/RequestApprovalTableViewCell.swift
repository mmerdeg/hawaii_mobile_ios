//
//  RequestApprovalTableViewCell.swift
//  Hawaii
//
//  Created by Server on 8/13/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol RequestApprovalProtocol: class {
    func requestAction(request: Request?, isAccepted: Bool, cell: RequestApprovalTableViewCell)
}

class RequestApprovalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var requestPerson: UILabel!
    
    @IBOutlet weak var requestDuration: UILabel!
    
    @IBOutlet weak var requestDates: UILabel!
    
    @IBOutlet weak var requestNotes: UILabel!
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var requestImageFrame: UIView!
    
    @IBOutlet weak var additionalDescHeight: NSLayoutConstraint!
    
    @IBOutlet weak var additionalDesc: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var requestReason: UILabel!
    
    weak var delegate: RequestApprovalProtocol?
    
    var request: Request? {
        didSet {
            guard let notes = request?.reason,
                  let imageUrl = request?.absence?.iconUrl,
                  let duration = request?.days?.first?.duration?.description,
                  let startDate = request?.days?.first?.date,
                  let endDate = request?.days?.last?.date,
                  let reason = request?.absence?.name,
                  let color = request?.requestStatus?.backgoundColor,
                  let status = request?.requestStatus,
                  let userFullname = request?.user?.fullName else {
                    return
            }
            
            date.text = "submission date"
            requestNotes.text = notes
            requestDuration.text = String(duration)
            requestPerson.text = userFullname
            requestReason.text = reason
            
            let formatter = DisplayedDateFormatter()
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            requestDates.text = start == end ? start : start + " - " + end
            cardView.backgroundColor = UIColor.lightPrimaryColor
            date.text = convertDateString(dateString: request?.submissionTime ?? "",
                                          fromFormat: "yyyy-MM-dd'T'HH:mm:ss",
                                          toFormat: "dd.MM.yyyy.")
            
            requestImage.kf.setImage(with: URL(string: ViewConstants.baseUrl + "/" + imageUrl))
            requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.primaryColor
            requestImage.backgroundColor = color
            requestImage.layer.cornerRadius = requestImage.frame.height / 2
            requestImage.layer.masksToBounds = true
            requestImageFrame.backgroundColor = color
            requestImageFrame.layer.cornerRadius = requestImageFrame.frame.height / 2
            requestImageFrame.layer.masksToBounds = true
            
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.transparentColor.cgColor
            additionalDesc.backgroundColor = UIColor.cancelationPendingColor
            additionalDesc.layer.cornerRadius = 5
            additionalDesc.layer.borderColor = UIColor.canceledColor.cgColor
            additionalDesc.layer.masksToBounds = true
            if status != .cancelationPending {
                additionalDescHeight.constant = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.primaryColor
        selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func convertDateString(dateString: String, fromFormat sourceFormat: String, toFormat desFormat: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = sourceFormat
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = desFormat
        
        return dateFormatter.string(from: date ?? Date())
    }
    
    @IBAction func rejectClicked(_ sender: Any) {
        delegate?.requestAction(request: request, isAccepted: false, cell: self)
    }
    
    @IBAction func acceptClicked(_ sender: Any) {
        delegate?.requestAction(request: request, isAccepted: true, cell: self)
    }
}
