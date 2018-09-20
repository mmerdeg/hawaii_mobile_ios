//
//  CalendarCellCollectionViewCell.swift
//  Hawaii
//
//  Created by Server on 6/18/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Kingfisher

class CalendarCellCollectionViewCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
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
        roundedHalvesView.layer.cornerRadius = roundedHalvesView.frame.size.height * 2 / 3
    }
    
    func setCell(processor: ImageProcessor) {
        handleCellText(cellState: cellState)
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
            if cellState.dateBelongsTo != .thisMonth || request.requestStatus == RequestStatus.canceled
                || cellState.day == DaysOfWeek.saturday || cellState.day == DaysOfWeek.sunday {
                continue
            }
            dateLabel.textColor = UIColor.darkPrimaryColor
            
            DispatchQueue.main.async {
                switch day.duration {
                case .afternoon?:
                    self.afternoonView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                    self.afternoonImage.kf.setImage(with: URL(string: Constants.baseUrl + "/" + (request.absence?.iconUrl ?? "")))
                case .fullday?:
                    self.afternoonView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                    self.morningView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                    self.fullDayImage.kf.setImage(with: URL(string: Constants.baseUrl + "/" + (request.absence?.iconUrl ?? "")))
                    print()
                case .morning?:
                    self.morningView.backgroundColor = request.requestStatus?.backgoundColor ?? UIColor.clear
                    self.morningImage.kf.setImage(with: URL(string: Constants.baseUrl + "/" + (request.absence?.iconUrl ?? "")))
                default :
                    print("")
                }
            }
            
        }
        
        layoutIfNeeded()
    }
    
    func resetView(cellState: CellState) {
        morningView.backgroundColor = UIColor.clear
        morningImage.image = UIImage()
        morningImage.kf.setImage(with: URL(string: ""))
        afternoonView.backgroundColor = UIColor.clear
        afternoonImage.image = UIImage()
        afternoonImage.kf.setImage(with: URL(string: ""))
        fullDayImage.image = UIImage()
        fullDayImage.kf.setImage(with: URL(string: ""))
        handleCellText(cellState: cellState)
        layoutIfNeeded()
    }
    
}
