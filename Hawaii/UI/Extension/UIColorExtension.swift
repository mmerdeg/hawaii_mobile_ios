//
//  UIColorExtension.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class var darkPrimaryColor: UIColor {
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    class var primaryColor: UIColor {
        return #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
    }
    
    class var lightPrimaryColor: UIColor {
        return #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.2039215686, alpha: 1)
    }

    class var accentColor: UIColor {
        return #colorLiteral(red: 0.9843137255, green: 0.2941176471, blue: 0.3098039216, alpha: 1)
    }
    
    class var transparentColor: UIColor {
        return UIColor.clear
    }
    
    class var pendingColor: UIColor {
        return #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.2039215686, alpha: 1)
    }
    
    class var rejectedColor: UIColor {
        return #colorLiteral(red: 0.9490196078, green: 0.1843137255, blue: 0.4274509804, alpha: 1)
    }
    
    class var approvedColor: UIColor {
        return #colorLiteral(red: 0.2039215686, green: 0.9882352941, blue: 0.431372549, alpha: 1)
    }
    
    class var remainingColor: UIColor {
        return #colorLiteral(red: 0.2039215686, green: 0.8823529412, blue: 0.9882352941, alpha: 1)
    }
    
    class var primaryTextColor: UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    class var secondaryTextColor: UIColor {
        return #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1)
    }
}
