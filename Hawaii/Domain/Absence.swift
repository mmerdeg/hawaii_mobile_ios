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

enum AbsenceType: Int {
    case workFromHome = 0
    case vacation = 1
    case trainingAndEducation = 2
    case businessTravel = 3
    case deliveryOrAdoption = 4
    case familySaintDay = 5
    case funeralFamilyMember = 6
    case maternityLeave = 7
    case moving = 8
    case nationalSportCompetition = 9
    case ownWedding = 10
    case illnessOfFamilyMember = 11
    
    var image: UIImage? {
        switch self {
        case .workFromHome:
            return #imageLiteral(resourceName: "house")
        case .businessTravel:
            return #imageLiteral(resourceName: "airplane_mode_on")
        case .vacation:
            return #imageLiteral(resourceName: "vacation")
        case .trainingAndEducation:
            return #imageLiteral(resourceName: "vacation")
        case .deliveryOrAdoption:
            return #imageLiteral(resourceName: "vacation")
        case .familySaintDay:
            return #imageLiteral(resourceName: "vacation")
        case .funeralFamilyMember:
            return #imageLiteral(resourceName: "vacation")
        case .maternityLeave:
            return #imageLiteral(resourceName: "vacation")
        case .moving:
            return #imageLiteral(resourceName: "vacation")
        case .nationalSportCompetition:
            return #imageLiteral(resourceName: "vacation")
        case .ownWedding:
            return #imageLiteral(resourceName: "vacation")
        case .illnessOfFamilyMember:
            return #imageLiteral(resourceName: "vacation")
        }
    }
    
    var description: String {
        switch self {
        case .workFromHome:
            return "Work from home"
        case .businessTravel:
            return "Business travel"
        case .vacation:
            return "Annual leave - Vacation"
        case .trainingAndEducation:
            return "Training & Education"
        case .deliveryOrAdoption:
            return "Delivery or adoption"
        case .familySaintDay:
            return "Family Saint day"
        case .funeralFamilyMember:
            return "Funeral family member"
        case .maternityLeave:
            return "Maternity leave"
        case .moving:
            return "Moving"
        case .nationalSportCompetition:
            return "National sport competition"
        case .ownWedding:
            return "Own wedding"
        case .illnessOfFamilyMember:
            return "Serious illness of close family member"
        }
    }
}
