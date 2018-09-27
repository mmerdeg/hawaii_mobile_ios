//
//  RoundedTextView.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/24/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class RoundedTextView: UITextView {
    override func layoutSubviews() {
        super.layoutIfNeeded()
        self.layer.cornerRadius = 10
        self.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7544194799)
        self.clipsToBounds = true
    }
}
