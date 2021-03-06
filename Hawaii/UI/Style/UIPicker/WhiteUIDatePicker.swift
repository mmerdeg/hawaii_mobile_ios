import Foundation
import UIKit

@IBDesignable class WhiteUIDatePicker: UIDatePicker {
    
    override func layoutSubviews() {
        self.setValue(UIColor.primaryTextColor, forKey: "textColor")
        self.setValue(false, forKey: "highlightsToday")
        self.tintColor = UIColor.primaryTextColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.datePickerMode = .date
    }
}
