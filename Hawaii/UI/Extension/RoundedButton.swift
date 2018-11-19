import Foundation
import UIKit

class RoundedButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutIfNeeded()
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.accentColor.cgColor
    }
    
}
