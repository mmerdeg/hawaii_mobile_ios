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
<<<<<<< HEAD:Hawaii/UI/Style/UIPicker/WhiteUIPicker.swift
        self.setValue(UIColor.cyan, forKey: "textColor")
        self.setValue(true, forKey: "highlightsToday")
=======
        //self.layoutIfNeeded()
        self.tintColor = tintCustomColor
        self.setValue(tintCustomColor, forKey: "textColor")
>>>>>>> requests:Hawaii/UI/Style/UIPicker/WhiteUIDatePicker.swift
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
