//
//  RoundedImageView.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/19/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

class RoundedImageView: UIImageView {
    
    func makeRound() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.accentColor.cgColor
        self.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeRound()
    }
}
