//
//  PublicHolidayTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/7/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Kingfisher

class PublicHolidayTableViewCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    var cellState: CellState!
    
    func handleCellText(cellState: CellState) {
        dateLabel.text = cellState.text
        if Calendar.current.isDateInToday(cellState.date) {
            dateLabel.textColor = UIColor.accentColor
            self.isUserInteractionEnabled = true
            self.layer.borderColor = UIColor.cyan.cgColor
        } else {
            if NSCalendar.current.isDateInWeekend(cellState.date) || cellState.dateBelongsTo != .thisMonth {
                self.isUserInteractionEnabled = false
                dateLabel.textColor = UIColor.secondaryTextColor
            } else {
                self.isUserInteractionEnabled = true
                dateLabel.textColor = UIColor.primaryTextColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCell(processor: ImageProcessor) {
        handleCellText(cellState: cellState)
        self.layer.borderColor = UIColor.lightPrimaryColor.cgColor
        self.layer.borderWidth = 0.5
        layoutIfNeeded()
        
        self.backgroundColor = UIColor.cyan
        self.isUserInteractionEnabled = false
    }
    
    func resetView(cellState: CellState) {
        handleCellText(cellState: cellState)
        layoutIfNeeded()
    }
    
}