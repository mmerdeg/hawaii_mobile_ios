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
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    var tempTitleText: String!
    var tempDescText: String!
    var tempImage: UIImage!
    
    init(frame: CGRect, titleText: String, descText: String, backgroundImage: UIImage) {
        super.init(frame: frame)
        self.tempTitleText = titleText
        self.tempDescText = descText
        self.tempImage = backgroundImage
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.text = tempTitleText
        descLabel.text = tempDescText
        backgroundImage.image = tempImage
        addSubview(view)
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
