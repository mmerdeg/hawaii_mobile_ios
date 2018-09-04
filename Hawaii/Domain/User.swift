//
//  User.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct User: Codable {
    
    let id: Int?
    let teamId: Int?
    let leaveProfileId: Int?
    let fullName: String?
    let email: String?
    let userRole: String?
    let jobTitle: String?
    let active: Bool?
    let yearsOfService: Int?
    let allowances: [Allowance]?
    
}
