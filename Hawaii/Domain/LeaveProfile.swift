//
//  LeaveProfile.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/22/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct LeaveProfile: Codable {
    let id: Int?
    let comment: String?
    let entitlement: Int?
    let maxBonusDays: Int?
    let maxCarriedOver: Int?
    let name: String?
    let training: Int?
}
