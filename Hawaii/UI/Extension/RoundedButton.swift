import Foundation
import UIKit

class RoundedButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutIfNeeded()
        self.layer.cornerRadius = 10
        self.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7544194799)
        self.clipsToBounds = true
        self.imageView?.layer.masksToBounds = true
    }
    
}