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
    case afternoonFirst = "AFTERNOON-FIRST"
    case morningLast = "MORNING-LAST"
    case morningAndAfternoon = "MORNING-AFTERNOON"
    
    var description: String {
        switch self {
        case .fullday:
            return "Full day"
        case .morning:
            return "Morning only"
        case .afternoon:
            return "Afternoon only"
        case .afternoonFirst:
            return "Afternoon first day"
        case .morningLast:
            return "Morning last day"
        case .morningAndAfternoon:
            return "Afternoon first day and morning last day"
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
    
    init?(durationType: String) {
        switch durationType {
        case DurationType.fullday.description:
            self.init(rawValue: "FULL_DAY")
        case DurationType.morning.description:
            self.init(rawValue: "MORNING")
        case DurationType.afternoon.description:
            self.init(rawValue: "AFTERNOON")
        case DurationType.afternoonFirst.description:
            self.init(rawValue: "AFTERNOON-FIRST")
        case DurationType.morningLast.description:
            self.init(rawValue: "MORNING-LAST")
        case DurationType.morningAndAfternoon.description:
            self.init(rawValue: "MORNING-AFTERNOON")
        default:
            return nil
        }
    }
}
