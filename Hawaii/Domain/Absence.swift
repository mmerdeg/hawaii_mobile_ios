//
//  Absence.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

struct Absence {
    
    let id: Int?
    let comment: String?
    let absenceType: AbsenceType?
    let deducted: Bool?
    let active: Bool?
    let name: String?
    
}

enum AbsenceType {
    case workFromHome
    case business
    case vacation
    
    var image: UIImage? {
        switch self {
        case .workFromHome:
            return #imageLiteral(resourceName: "house")
        case .business:
            return #imageLiteral(resourceName: "airplane_mode_on")
        case .vacation:
            return #imageLiteral(resourceName: "vacation")
        }
    }
    var desc: String {
        switch self {
        case .workFromHome:
            return "Work from home"
        case .business:
            return "Business"
        case .vacation:
            return "Vacation"
        }
    }
}
