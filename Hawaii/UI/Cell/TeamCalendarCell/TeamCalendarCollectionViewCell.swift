import UIKit
import JTAppleCalendar
import Kingfisher

class TeamCalendarCollectionViewCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var isEmpty: UIView!
    var requests: [Request]?
    
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
        if requests?.isEmpty ?? true {
            self.isUserInteractionEnabled = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCell() {
        self.layer.borderColor = UIColor.lightPrimaryColor.cgColor
        handleCellText(cellState: cellState)
        isEmpty.layer.cornerRadius = isEmpty.frame.width / 2
        isEmpty.backgroundColor = requests?.isEmpty ?? true ||
            NSCalendar.current.isDateInWeekend(cellState.date) ||
            cellState.dateBelongsTo != .thisMonth ? UIColor.transparentColor: UIColor.accentColor
        self.layer.borderWidth = 0.5
        layoutIfNeeded()
    }
    
    func resetView(cellState: CellState) {
        handleCellText(cellState: cellState)
        layoutIfNeeded()
    }
    
}
