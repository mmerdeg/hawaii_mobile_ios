//
//  UIButtonExtension.swift
//  Hawaii
//
//  Created by Server on 6/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutIfNeeded()
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.clipsToBounds = true
        self.imageView?.layer.masksToBounds = true
    }
    
}
