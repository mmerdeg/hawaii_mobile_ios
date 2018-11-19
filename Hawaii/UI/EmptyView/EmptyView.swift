//
//  EmptyView.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/13/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

class EmptyView: UIView {
    
    var view: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    var tempTitleText: String?
    var tempImage: UIImage?
    
    let imageRotationAngle = 0.1
    
    init(frame: CGRect, titleText: String, backgroundImage: UIImage) {
        super.init(frame: frame)
        self.tempTitleText = titleText
        self.tempImage = backgroundImage
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        print("ads")
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.text = tempTitleText ?? ""
        backgroundImage.image = tempImage ?? UIImage()
        backgroundImage.transform = backgroundImage.transform.rotated(by: CGFloat(-imageRotationAngle))
        rotateView(targetView: backgroundImage)
        addSubview(view)
    }
    
    private func rotateView(targetView: UIView, duration: Double = 0.3) {
        
        UIView.animate(withDuration: duration, delay: 0, options: [.repeat, .autoreverse], animations: {
            
            targetView.transform = targetView.transform.rotated(by: CGFloat(2 * self.imageRotationAngle))
            
        }, completion: nil)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: EmptyView.self), bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else {
            return UIView()
        }
        
        return view
    }
}
