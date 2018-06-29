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
                  let image = request?.absence?.absenceType?.image,
                  let color = request?.requestStatus?.backgoundColor else {
                    return
            }
            requestReason.text = reason
            requestImage.image = image.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.white
            requestImage.backgroundColor = color
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.transparentColor.cgColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
