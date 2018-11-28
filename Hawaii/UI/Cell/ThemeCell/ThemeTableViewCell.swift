import UIKit
import SwinjectStoryboard

class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var themeLabel: UILabel!
    
    @IBOutlet weak var themeSwitch: UISwitch!
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        themeLabel.text = LocalizedKeys.More.theme.localized()
        themeLabel.textColor = UIColor.black
        themeSwitch.onTintColor = UIColor.accentColor
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        UIColor.initWithColorScheme(colorScheme: themeSwitch.isOn ? .light : .dark)
        
        if let userDetailsUseCase = userDetailsUseCase {
            userDetailsUseCase.setLightThemeSelected(themeSwitch.isOn)
        }
    }

}
