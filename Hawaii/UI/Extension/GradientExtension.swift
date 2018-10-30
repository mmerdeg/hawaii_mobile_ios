//
//  GradientExtension.swift
//  Hawaii
//
//  Created by Ivan Divljak on 10/23/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor], locations: [NSNumber], navigation: Bool) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        startPoint = CGPoint(x: 0, y: 1)
        self.locations = locations
        endPoint = CGPoint(x: 1, y: 0)
    }
    
    /**
     Returns image that has gradient in it.
     
     - Returns: Image that has gradient.
     */
    func createGradientImage() -> UIImage? {
        
        var image: UIImage?
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
}
