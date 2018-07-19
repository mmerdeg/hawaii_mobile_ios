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
        return #colorLiteral(red: 0.9695792598, green: 0.290657306, blue: 0.2377437937, alpha: 1)
    }
    
//    class var accentColor: UIColor {
//        return #colorLiteral(red: 0.2597557107, green: 0.2549137603, blue: 0.2586930243, alpha: 1)
//    }
//
//    class var secondaryColor: UIColor {
//        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//    }
    
    class var secondaryColor: UIColor {
        return #colorLiteral(red: 0.1989014137, green: 0.1940186209, blue: 0.1991979244, alpha: 1)
    }

    class var accentColor: UIColor {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    class var transparentColor: UIColor {
        return UIColor.clear
    }
    
    class var pendingColor: UIColor {
//        return #colorLiteral(red: 0.9764705896, green: 0.8909658744, blue: 0.494516749, alpha: 1)
        return #colorLiteral(red: 0.9764705896, green: 0.940397389, blue: 0, alpha: 1)
    }
    
    class var rejectedColor: UIColor {
//        return #colorLiteral(red: 1, green: 0.5831070909, blue: 0.5286697807, alpha: 1)
        return #colorLiteral(red: 0.9764705896, green: 0.1541128263, blue: 0.4167465344, alpha: 1)
    }
    
    class var approvedColor: UIColor {
//        return #colorLiteral(red: 0.4908183156, green: 0.822766493, blue: 0.5365492381, alpha: 1)
        return #colorLiteral(red: 0.0009907039545, green: 0.9764705896, blue: 0.3293116906, alpha: 1)
    }
    
    class var inactiveColor: UIColor {
        return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    class var selectionColor: UIColor {
        return #colorLiteral(red: 0.1683397346, green: 0.1683397346, blue: 0.1683397346, alpha: 1)
    }
}
