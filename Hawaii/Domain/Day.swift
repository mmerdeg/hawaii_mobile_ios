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

enum DurationType: Int {
    
    case fullday = 0
    case morning = 1
    case afternoon = 2
    
    var description: String {
        switch self {
        case .fullday:
            return "Full day"
        case .morning:
            return "Morning only"
        case .afternoon:
            return "Afternoon only"
        }
    }
}
