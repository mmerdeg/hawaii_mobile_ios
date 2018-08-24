//
//  ButtonStyleExtension.swift
//
//  Created by Marko Stajic on 3/29/17.
//  Copyright © 2017 Execom. All rights reserved.
//

import UIKit
import ECFoundationiOS

extension ButtonStyle {
    
    public class func clear() -> ButtonStyle {
        return ButtonStyle(backgroundColor: UIColor.accentColor, titleColor: UIColor.primaryTextColor,
                           cornerRadius: 10.0, styleName: "clear", font: UIFont.primary(),
                           numberOfLines: 1, lineBreakMode: .byClipping, textAligment: .center)
    }
}
