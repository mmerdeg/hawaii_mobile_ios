//
//  Day.swift
//  Hawaii
//
//  Created by Server on 6/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

enum DurationType: String, Codable {
    
    case fullday = "FULL_DAY"
    case morning = "MORNING"
    case afternoon = "AFTERNOON"
    
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

struct Day: Codable {
    
    let id: Int?
    let date: Date?
    let duration: DurationType?
    let requestId: Int?
    
    
    
}

extension DurationType {
    init?(durationType: Int) {
        switch durationType {
        case 0:
            self.init(rawValue: "FULL_DAY")
        case 1:
            self.init(rawValue: "MORNING")
        case 2:
            self.init(rawValue: "AFTERNOON")
        default:
            return nil
        }
    }
}
