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
    case nonDecuted = "NON_DEDUCTED_LEAVE"
}

struct Absence: Codable {
    let id: Int?
    let name: String?
    let absenceSubtype: String?
    let absenceType: String?
    let comment: String?
    let active: Bool?
    let iconUrl: String?
}
extension Absence {
    init(absence: Absence? = nil, id: Int? = nil, name: String? = nil, absenceSubtype: String? = nil ,
         absenceType: String? = nil, comment: String? = nil, active: Bool? = nil,
         iconUrl: String? = nil) {
        self.id = id ?? absence?.id
        self.name = name ?? absence?.name
        self.absenceSubtype = absenceSubtype ?? absence?.absenceSubtype
        self.absenceType = absenceType ?? absence?.absenceType
        self.comment = comment ?? absence?.comment
        self.active = active ?? absence?.active
        self.iconUrl = iconUrl ?? absence?.iconUrl
        
    }
}
