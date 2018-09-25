//
//  TeamPreviewTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class TeamPreviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var requestImageFrame: UIView!
    
    @IBOutlet weak var requestOwner: UILabel!

    weak var requestCancelationDelegate: RequestCancelationProtocol?
    
    var request: Request? {
        didSet {
            guard let notes = request?.user?.fullName,
                let imageUrl = request?.absence?.iconUrl,
                let color = request?.requestStatus?.backgoundColor else {
                    return
            }
            requestOwner.text = notes
            requestImage.kf.setImage(with: URL(string: Constants.baseUrl + "/" + imageUrl))
            requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.primaryColor
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
        // Initialization code
        //backgroundColor = UIColor.primaryColor
        selectionStyle = UITableViewCellSelectionStyle.none
    }
}
