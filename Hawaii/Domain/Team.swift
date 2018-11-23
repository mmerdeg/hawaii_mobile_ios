//
//  Team.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct Team: Codable, Equatable {
    let active: Bool?
    let emails: String?
    let id: Int?
    let name: String?
    let teamApprovers: [User]?
}

extension Team {
    
    init(team: Team? = nil, values: [String: Any?], teamApprovers: [User]? = nil) {
        self.id = team?.id
        self.emails = values["email"] as? String ?? team?.emails
        self.active = values["active"] as? Bool ?? team?.active
        self.name = values["name"] as? String ?? team?.name
        self.teamApprovers = teamApprovers ?? team?.teamApprovers
    }
    
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id
    }
}
