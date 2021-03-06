import Foundation
import UIKit

class RoundedView: UIView {
    
    override func layoutSubviews() {
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        self.layoutIfNeeded()
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
}
