//
//  LeaveProfile.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/22/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct LeaveProfile: Codable, Equatable, Hashable {
    let id: Int?
    let comment: String?
    let entitlement: Int?
    let maxBonusDays: Int?
    let maxCarriedOver: Int?
    let name: String?
    let training: Int?
}

extension LeaveProfile {
    init(leaveProfile: LeaveProfile? = nil, values: [String: Any?]) {
        self.id = leaveProfile?.id
        self.comment = values["comment"] as? String ?? leaveProfile?.comment
        self.name = values["name"] as? String ?? leaveProfile?.name
        self.entitlement = values["entitlement"] as? Int ?? leaveProfile?.entitlement
        self.maxBonusDays = values["maxBonusDays"] as? Int ?? leaveProfile?.maxBonusDays
        self.training = values["training"] as? Int ?? leaveProfile?.training
        self.maxCarriedOver = values["maxCarriedOver"] as? Int ?? leaveProfile?.maxCarriedOver
    }
    
    init(leaveProfile: LeaveProfile? = nil, id: Int? = nil,
         comment: String? = nil, name: String? = nil, entitlement: Int? = nil,
         maxBonusDays: Int? = nil, maxCarriedOver: Int? = nil, training: Int? = nil, users: [User]? = nil) {
        self.id = id ?? leaveProfile?.id
        self.comment = comment ?? leaveProfile?.comment
        self.name = name ?? leaveProfile?.name
        self.entitlement = entitlement ?? leaveProfile?.entitlement
        self.maxBonusDays = maxBonusDays ?? leaveProfile?.maxBonusDays
        self.training = training ?? leaveProfile?.training
        self.maxCarriedOver = maxCarriedOver ?? leaveProfile?.maxCarriedOver
    }
    
    static func == (lhs: LeaveProfile, rhs: LeaveProfile) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
