//
//  WhiteUIPicker.swift
//  ECFoundationiOS
//
//  Created by Server on 6/29/18.
//

import Foundation
import UIKit

@IBDesignable class WhiteUIPicker: UIDatePicker {
    
    @IBInspectable var tintCustomColor: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        //self.layoutIfNeeded()
        self.tintColor = tintCustomColor
        self.setValue(tintCustomColor, forKey: "textColor")
        self.setValue(false, forKey: "highlightsToday")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // custom setup
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        // custom setup
    }
}
