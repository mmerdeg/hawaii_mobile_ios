//
//  RequestDetailTableViewCell.swift
//  Hawaii
//
//  Created by Server on 6/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class RequestDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var requestHours: UILabel!
    @IBOutlet weak var requestNumberOfDays: UILabel!
    @IBOutlet weak var requestEndDate: UILabel!
    @IBOutlet weak var requestStartDate: UILabel!
    @IBOutlet weak var requestReason: UILabel!
    
    @IBOutlet weak var requestImage: UIImageView!
    var request: Request? {
        didSet {
            guard let reason = request?.reason,
                  let endDate = request?.days?.first?.date,
                  let image = request?.absence?.absenceType?.image,
                  let color = request?.requestStatus?.backgoundColor else {
                    return
            }
            requestReason.text = reason
            requestEndDate.text = endDate.description
            requestImage.image = image
            requestImage.backgroundColor = color
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
