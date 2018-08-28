//
//  WhiteUIPicker.swift
//  ECFoundationiOS
//
//  Created by Server on 6/29/18.
//

import Foundation
import UIKit

@IBDesignable class WhiteUIDatePicker: UIDatePicker {
    
    @IBInspectable var tintCustomColor: UIColor = UIColor.primaryTextColor {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        //self.layoutIfNeeded()
        self.tintColor = tintCustomColor
        self.setValue(tintCustomColor, forKey: "textColor")
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
