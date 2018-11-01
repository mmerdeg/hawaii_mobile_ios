import Foundation
import ECFoundationiOS

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
