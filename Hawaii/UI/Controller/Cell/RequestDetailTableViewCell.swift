//
//  RequestDetailTableViewCell.swift
//  Hawaii
//
//  Created by Server on 6/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class RequestDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var requestNumberOfDays: UILabel!
    @IBOutlet weak var requestStartDate: UILabel!
    @IBOutlet weak var requestReason: UILabel!
    @IBOutlet weak var requestImage: UIImageView!
    
    var request: Request? {
        didSet {
            guard let reason = request?.reason,
                let imageUrl = request?.absence?.iconUrl,
                let color = request?.requestStatus?.backgoundColor else {
                    return
            }
            requestReason.text = reason
            requestImage.kf.setImage(with: URL(string: imageUrl))
            requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.primaryTextColor
            requestImage.backgroundColor = color
            date.text = String(describing: request?.id ?? -1)
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
    
}
