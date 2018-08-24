//
//  RequestApprovalTableViewCell.swift
//  Hawaii
//
//  Created by Server on 8/13/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol RequestApprovalProtocol: class {
    func requestAction(request: Request?, isAccepted: Bool)
}

class RequestApprovalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var requestPerson: UILabel!
    
    @IBOutlet weak var requestDuration: UILabel!
    
    @IBOutlet weak var requestDates: UILabel!
    
    @IBOutlet weak var requestReason: UILabel!
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: RequestApprovalProtocol?
    
    var request: Request? {
        didSet {
            guard let reason = request?.reason,
                let imageUrl = request?.absence?.iconUrl,
                let duration = request?.days?.first?.duration?.description,
                let startDate = request?.days?.first?.date,
                let endDate = request?.days?.last?.date,
                let color = request?.requestStatus?.backgoundColor else {
                    return
            }
            
            date.text = "submission date"
            requestReason.text = reason
            requestDuration.text = String(duration)
            requestPerson.text = "Ime Prezime"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy."
            requestDates.text = formatter.string(from: startDate) + " - " + formatter.string(from: endDate)
            
            requestImage.kf.setImage(with: URL(string: Constants.baseUrl + "/" + imageUrl))
            requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.primaryTextColor
            requestImage.backgroundColor = color
            requestImage.layer.cornerRadius = requestImage.frame.height / 2
            requestImage.layer.masksToBounds = true
            
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.transparentColor.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = UIColor.primaryColor
        selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    @IBAction func rejectClicked(_ sender: Any) {
        delegate?.requestAction(request: request, isAccepted: false)
    }
    
    @IBAction func acceptClicked(_ sender: Any) {
        delegate?.requestAction(request: request, isAccepted: true)
    }
}
