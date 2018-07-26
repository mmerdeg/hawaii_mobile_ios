//
//  DialogWrapper.swift
//  Hawaii
//
//  Created by Server on 7/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct DialogWrapper {
    
    let title: String?
    let uiAction: UIAlertActionStyle?
    let image: UIImage?
    let handler: ((UIAlertAction) -> Void)?
    
    init(dialogWrapper: DialogWrapper? = nil, title: String? = nil, uiAction: UIAlertActionStyle? = nil, image: UIImage? = nil,
         handler: ((UIAlertAction) -> Void)? = nil) {
        self.title = title ?? dialogWrapper?.title
        self.uiAction = uiAction ?? dialogWrapper?.uiAction
        self.image = image ?? dialogWrapper?.image
        self.handler = handler ?? dialogWrapper?.handler
    }
}
