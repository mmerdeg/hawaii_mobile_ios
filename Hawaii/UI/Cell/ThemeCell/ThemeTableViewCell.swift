import UIKit
import SwinjectStoryboard

class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var themeLabel: UILabel!
    
    @IBOutlet weak var themeSwitch: UISwitch!
    
    var userDetailsUseCase: UserDetailsUseCase?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        themeLabel.text = LocalizedKeys.More.theme.localized()
        themeLabel.textColor = UIColor.black
        themeSwitch.onTintColor = UIColor.accentColor
        themeSwitch.tintColor = UIColor.accentColor
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        UIColor.initWithColorScheme(colorScheme: themeSwitch.isOn ? .light : .dark)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.themeChanged),
                                        object: nil, userInfo: nil)
        
        if let userDetailsUseCase = userDetailsUseCase {
            userDetailsUseCase.setLightThemeSelected(themeSwitch.isOn)
        }
    }

}
