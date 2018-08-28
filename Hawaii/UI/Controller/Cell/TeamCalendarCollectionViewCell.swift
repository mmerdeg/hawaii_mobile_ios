//
//  TeamCalendarCollectionViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Kingfisher

class TeamCalendarCollectionViewCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var requests: [Request]?
    
    var cellState: CellState!
    
    func handleCellText(cellState: CellState) {
        dateLabel.text = cellState.text
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCell(processor: ImageProcessor) {
        handleCellText(cellState: cellState)
        self.layer.borderColor = UIColor.lightPrimaryColor.cgColor
        self.backgroundColor = UIColor.lightPrimaryColor
        self.layer.borderWidth = 0.5
        layoutIfNeeded()
    }
    
    func resetView(cellState: CellState) {
        handleCellText(cellState: cellState)
        layoutIfNeeded()
    }
    
}
