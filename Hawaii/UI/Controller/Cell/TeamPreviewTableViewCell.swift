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
    
    @IBOutlet weak var requestOwner: UILabel!

    weak var requestCancelationDelegate: RequestCancelationProtocol?
    
    var request: Request? {
        didSet {
            guard let notes = request?.reason,
                  let imageUrl = request?.absence?.iconUrl else {
                    return
            }
            requestOwner.text = notes
            requestImage.kf.setImage(with: URL(string: imageUrl))
            requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.primaryColor
            requestImage.layer.cornerRadius = requestImage.frame.height / 2
            requestImage.layer.masksToBounds = true
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
