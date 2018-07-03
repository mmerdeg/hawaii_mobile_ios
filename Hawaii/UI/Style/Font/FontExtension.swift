//
//  FontExtension.swift
//
//  Created by Marko Stajic on 3/27/17.
//  Copyright © 2017 Execom. All rights reserved.
//

import UIKit
import ECFoundationiOS

extension Font {
    
    public class func primary() -> Font {
        return Font(font: UIFont.primary(), color: UIColor.accentColor, fontName: "fontPrimary")
    }
    
    public class func red() -> Font {
        return Font(font: UIFont.red(), color: UIColor.primaryColor, fontName: "fontRed")
    }

}
