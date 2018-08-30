//
//  WhiteUIPicker.swift
//  ECFoundationiOS
//
//  Created by Server on 6/29/18.
//

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
        // custom setup
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        // custom setup
        self.datePickerMode = .date
    }
}
