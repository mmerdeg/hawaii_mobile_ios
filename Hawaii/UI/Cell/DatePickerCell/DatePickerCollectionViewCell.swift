import UIKit
import JTAppleCalendar
import Kingfisher

class DatePickerCollectionViewCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var cellState: CellState!
    
    func handleCellText(cellState: CellState) {
        dateLabel.text = cellState.text
        if Calendar.current.isDateInToday(cellState.date) {
            self.isUserInteractionEnabled = true
            dateLabel.textColor = UIColor.primaryTextColor
            self.layer.borderColor = UIColor.primaryTextColor.cgColor
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
    
    func setCell() {
        self.layer.borderColor = UIColor.lightPrimaryColor.cgColor
        handleCellText(cellState: cellState)
        self.layer.borderWidth = 0.5
        layoutIfNeeded()
    }
    
    func resetView(cellState: CellState) {
        handleCellText(cellState: cellState)
        layoutIfNeeded()
    }
    
}
