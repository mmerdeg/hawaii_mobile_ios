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
    
    class var primaryColor: UIColor {
        return #colorLiteral(red: 1, green: 0.3524264984, blue: 0.3430640954, alpha: 1)
    }
    
    class var secondaryColor: UIColor {
        return #colorLiteral(red: 0.2597557107, green: 0.2549137603, blue: 0.2586930243, alpha: 1)
    }
    
    class var accentColor: UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    class var transparentColor: UIColor {
        return UIColor.clear
    }
    
    class var pendingColor: UIColor {
        return #colorLiteral(red: 0.9666472319, green: 0.9123402739, blue: 0.001999657253, alpha: 1)
    }
    
    class var rejectedColor: UIColor {
        return #colorLiteral(red: 1, green: 0.4682553879, blue: 0.371436171, alpha: 1)
    }
    
    class var approvedColor: UIColor {
        return #colorLiteral(red: 0.01436121868, green: 0.7305877221, blue: 0.02162263702, alpha: 1)
    }
    
}
