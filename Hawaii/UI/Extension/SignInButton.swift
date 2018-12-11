//
//  SignInButton.swift
//  Hawaii
//
//  Created by Server on 11/6/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

class SignInButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.cornerRadius = 3
        self.setImage(UIImage(named: "google"), for: .normal)
        let title = LocalizedKeys.General.signIn.localized()
    
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
                     NSAttributedString.Key.foregroundColor: UIColor.black]
        let boldString = NSMutableAttributedString(string: title, attributes: attrs)
        self.setAttributedTitle(boldString, for: .normal)
        
        self.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        guard let imageView = self.imageView else {
                return
        }
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageView.frame.size.width, bottom: 0, right: 0)
    }
}
