import Foundation
import UIKit

enum ColorScheme {
    case light, dark
}

extension UIColor {

//    @nonobjc static var darkPrimaryColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//
//    @nonobjc static var primaryColor: UIColor = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
//
//    @nonobjc static var lightPrimaryColor: UIColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.2039215686, alpha: 1)
//
//    @nonobjc static var primaryTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//
//    @nonobjc static var tabBarItemColor: UIColor = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    
    @nonobjc static var darkPrimaryColor: UIColor = #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1)

    @nonobjc static var primaryColor: UIColor = #colorLiteral(red: 0.8659581218, green: 0.8659581218, blue: 0.8659581218, alpha: 1)

    @nonobjc static var lightPrimaryColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    @nonobjc static var primaryTextColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    @nonobjc static var tabBarItemColor: UIColor = #colorLiteral(red: 0.3351443528, green: 0.3351443528, blue: 0.3351443528, alpha: 1)
    
    static func initWithColorScheme(colorScheme: ColorScheme) {
        switch colorScheme {
        case .light:
            darkPrimaryColor = #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1)
            primaryColor = #colorLiteral(red: 0.8659581218, green: 0.8659581218, blue: 0.8659581218, alpha: 1)
            lightPrimaryColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            primaryTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tabBarItemColor = #colorLiteral(red: 0.3351443528, green: 0.3351443528, blue: 0.3351443528, alpha: 1)
        case .dark:
            darkPrimaryColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            primaryColor = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
            lightPrimaryColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.2039215686, alpha: 1)
            primaryTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            tabBarItemColor = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        }
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
    
    class var sickColor: UIColor {
        return accentColor
    }
    
    class var approvedColor: UIColor {
        return #colorLiteral(red: 0.1803921569, green: 0.7568627451, blue: 0.1764705882, alpha: 1)
    }
    class var remainingColor: UIColor {
        return #colorLiteral(red: 0.2039215686, green: 0.8823529412, blue: 0.9882352941, alpha: 1)
    }
    
    class var canceledColor: UIColor {
        return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    class var cancelationPendingColor: UIColor {
        return #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
    }
    
    class var secondaryTextColor: UIColor {
        return #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1)
    }
    
    class var statusIconColor: UIColor {
        return #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
    }
}
