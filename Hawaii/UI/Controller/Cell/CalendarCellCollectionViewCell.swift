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
    
    @IBOutlet weak var leaveImage: UIImageView!
    
    @IBOutlet weak var morningView: UIView!
    @IBOutlet weak var morningImage: UIImageView!
    
    @IBOutlet weak var afternoonView: UIView!
    @IBOutlet weak var afternoonImage: UIImageView!
    
    var requests: [Request]?
    var cellState: CellState!
    
    func handleCellText(cellState: CellState) {
        dateLabel.text = cellState.text
        if Calendar.current.isDateInToday(cellState.date) {
            dateLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else {
            dateLabel.textColor = cellState.dateBelongsTo == .thisMonth ? UIColor.accentColor : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }
    
    func handleCellSelection(cellState: CellState) {
        if Calendar.current.isDateInToday(cellState.date) {
            circleView.isHidden = false
            circleView.backgroundColor = #colorLiteral(red: 1, green: 0.2457885742, blue: 0.2937521338, alpha: 1)
        } else {
            circleView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            circleView.isHidden = cellState.dateBelongsTo == .thisMonth ? !cellState.isSelected : true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setCell() {
        handleCellText(cellState: cellState)
        handleCellSelection(cellState: cellState)
        self.layer.borderColor = UIColor.accentColor.cgColor
        self.layer.borderWidth = 0.5
        guard let requests = requests else {
            resetView()
            return
        }
        
        for request in requests {
            guard let day = request.days?.first else {
                continue
            }
            switch day.duration {
                
            case .afternoon:
                afternoonView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                afternoonImage.image = request.absence?.absenceType?.image ?? UIImage()
                leaveImage.image = UIImage()
            case .fullday:
                morningView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                afternoonView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                leaveImage.image = request.absence?.absenceType?.image ?? UIImage()
                morningImage.image = UIImage()
                afternoonImage.image = UIImage()
            case .morning:
                morningView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                morningImage.image = request.absence?.absenceType?.image ?? UIImage()
                leaveImage.image = UIImage()
            }
        }
        layoutIfNeeded()
    }
    
    func resetView() {
        morningView.backgroundColor = UIColor.clear
        morningImage.image = UIImage()
        afternoonView.backgroundColor = UIColor.clear
        afternoonImage.image = UIImage()
        leaveImage.image = UIImage()
        layoutIfNeeded()
    }
    
}
