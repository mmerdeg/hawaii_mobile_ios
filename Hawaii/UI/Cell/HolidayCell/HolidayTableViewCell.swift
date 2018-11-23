//
//  HolidayTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/19/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class HolidayTableViewCell: UITableViewCell {

    @IBOutlet weak var holidayImage: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var holiday: PublicHoliday? {
        didSet {
            guard let holidayName = holiday?.name,
                let holidayDate = holiday?.date else {
                    return
            }
            let formatter = DisplayedDateFormatter()
            self.dateLabel.text = formatter.string(from: holidayDate)
            self.nameLabel.text = holidayName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.primaryColor
    }
    
}
