import UIKit
import ECFoundationiOS

extension ButtonStyle {
    
    public class func clear() -> ButtonStyle {
        return ButtonStyle(backgroundColor: UIColor.accentColor, titleColor: UIColor.primaryTextColor,
                           cornerRadius: 10.0, styleName: "clear", font: UIFont.primary(),
                           numberOfLines: 1, lineBreakMode: .byClipping, textAligment: .center)
    }
}
