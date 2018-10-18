//
//  DtoDateFormatter.swift
//  Hawaii
//
//  Created by Server on 10/17/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class DtoDateFormatter: DateFormatter {
    
    let format = "yyyy-MM-dd"
    let zone = "UTC"
    
    override init() {
        super.init()
        dateFormat = format
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
