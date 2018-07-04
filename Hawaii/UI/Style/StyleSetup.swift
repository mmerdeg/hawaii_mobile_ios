//
//  StyleSetup.swift
//  Hawaii
//
//  Created by Server on 6/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import ECFoundationiOS

/// Style registration class.
class StyleSetup {
    
    /**
     Register all of the custom styles.
     */
    static func setStyles() {
        
        ButtonStyleManager.styles = [
            "redAndRounded": ButtonStyle.clear()
        ]
        
        FontManager.fonts = [
            "fontPrimary": Font.primary(),
            "calendarDaysFont": Font.calendarDaysFont()
        ]
        
    }
    
}
