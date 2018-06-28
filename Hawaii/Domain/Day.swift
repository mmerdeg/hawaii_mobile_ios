//
//  Day.swift
//  Hawaii
//
//  Created by Server on 6/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct Day {
    
    let id: Int?
    let date: Date
    let duration: DurationType
    
}

enum DurationType: String {
    
    case fullday = "FULLDAY"
    case morning = "MORNING"
    case afternoon = "AFTERNOON"
    
}
