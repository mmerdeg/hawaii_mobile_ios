//
//  Absence.swift
//  Hawaii
//
//  Created by Server on 8/24/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

enum AbsenceType: String, Codable {
    case deducted = "DEDUCTED_LEAVE"
    case sick = "SICKNESS"
    case bonus = "BONUS_DAYS"
    case nonDecuted = "NONDEDUCTED_LEAVE"
}

enum AbsenceSubType: Int, Codable {
    
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

struct Absence: Codable {
    let id: Int?
    let name: String?
    let absenceSubType: String?
    let absenceType: String?
    let comment: String?
    let active: Bool?
    let iconUrl: String?
}
extension Absence {
    init(absence: Absence? = nil, id: Int? = nil, name: String? = nil, absenceSubType: String? = nil ,
         absenceType: String? = nil, comment: String? = nil, active: Bool? = nil,
         iconUrl: String? = nil) {
        self.id = id ?? absence?.id
        self.name = name ?? absence?.name
        self.absenceSubType = absenceSubType ?? absence?.absenceSubType
        self.absenceType = absenceType ?? absence?.absenceType
        self.comment = comment ?? absence?.comment
        self.active = active ?? absence?.active
        self.iconUrl = iconUrl ?? absence?.iconUrl
        
    }
}
