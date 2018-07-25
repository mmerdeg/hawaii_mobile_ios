//
//  CalendarCellCollectionViewCell.swift
//  Hawaii
//
//  Created by Server on 6/18/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCellCollectionViewCell: JTAppleCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var circleView: UIView!
    
    @IBOutlet weak var fullDayImage: UIImageView!
    
    @IBOutlet weak var morningView: UIView!
    
    @IBOutlet weak var morningImage: UIImageView!
    
    @IBOutlet weak var afternoonView: UIView!
    
    @IBOutlet weak var afternoonImage: UIImageView!
    
    @IBOutlet weak var roundedHalvesView: UIView!
    
    var requests: [Request]?
    var cellState: CellState!
    
    func handleCellText(cellState: CellState) {
        dateLabel.text = cellState.text
        if Calendar.current.isDateInToday(cellState.date) {
            dateLabel.textColor = UIColor.accentColor
        } else {
            dateLabel.textColor = cellState.dateBelongsTo == .thisMonth ?
                UIColor.primaryTextColor : UIColor.secondaryTextColor
        }
    }
    
    func handleCellSelection(cellState: CellState) {
        circleView.backgroundColor = UIColor.primaryColor
        circleView.isHidden = !Calendar.current.isDateInToday(cellState.date)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedHalvesView.layer.cornerRadius = roundedHalvesView.frame.size.height * 2 / 3
    }
    
    func setCell() {
        handleCellText(cellState: cellState)
        handleCellSelection(cellState: cellState)
        self.layer.borderColor = UIColor.lightPrimaryColor.cgColor
        self.backgroundColor = UIColor.lightPrimaryColor
        self.layer.borderWidth = 0.5
        guard let requests = requests else {
            resetView(cellState: cellState)
            return
        }
        resetView(cellState: cellState)
        
        for request in requests {
            guard let day = request.days?.first else {
                continue
            }
            switch day.duration {

            case .afternoon:
                afternoonView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                afternoonImage.image = request.absence?.absenceType?.image ?? UIImage()
            case .fullday:
                afternoonView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                morningView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                fullDayImage.image = request.absence?.absenceType?.image ?? UIImage()
            case .morning:
                morningView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                morningImage.image = request.absence?.absenceType?.image ?? UIImage()
            }
        }
        dateLabel.textColor = UIColor.darkPrimaryColor
        
        layoutIfNeeded()
    }
    
    func resetView(cellState: CellState) {
        morningView.backgroundColor = UIColor.clear
        morningImage.image = UIImage()
        afternoonView.backgroundColor = UIColor.clear
        afternoonImage.image = UIImage()
        fullDayImage.image = UIImage()
        handleCellText(cellState: cellState)
        layoutIfNeeded()
    }
    
}
