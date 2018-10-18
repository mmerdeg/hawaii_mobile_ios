//
//  DisplayedDateFormatter.swift
//  Hawaii
//
//  Created by Server on 10/17/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class DisplayedDateFormatter: DateFormatter {
    
    let format = "dd.MM.yyyy."
    
    override init() {
        super.init()
        dateFormat = format
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
