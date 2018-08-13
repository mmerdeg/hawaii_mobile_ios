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
    @IBOutlet weak var requestNumberOfDays: UILabel!
    @IBOutlet weak var requestStartDate: UILabel!
    @IBOutlet weak var requestReason: UILabel!
    @IBOutlet weak var requestImage: UIImageView!
    
    weak var delegate: RequestApprovalProtocol?
    
    var request: Request? {
        didSet {
            guard let reason = request?.reason,
                let imageUrl = request?.absence?.iconUrl,
                let color = request?.requestStatus?.backgoundColor else {
                    return
            }
            date.text = String(describing: request?.id ?? 1)
            requestReason.text = reason
            requestImage.kf.setImage(with: URL(string: Constants.baseUrl + "/" + imageUrl))
            requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.primaryTextColor
            requestImage.backgroundColor = color
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
