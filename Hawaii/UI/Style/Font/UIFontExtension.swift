//
//  UIFontExtension.swift
//
//  Created by Marko Stajic on 3/27/17.
//  Copyright © 2017 Execom. All rights reserved.
//

import UIKit

@IBDesignable public extension UIFont {
    
    public class func primary() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }
    
}
