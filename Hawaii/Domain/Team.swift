//
//  Team.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct Team: Codable {
    let active: Bool?
    let emails: String?
    let id: Int?
    let name: String?
    let teamApprovers: [User]?
    let users: [User]?
}

extension Team: Equatable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Team: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Team {
    
    init(team: Team? = nil, values: [String: Any?], teamApprovers: [User]? = nil) {
        self.id = team?.id
        self.emails = values["email"] as? String ?? team?.emails
        self.active = values["active"] as? Bool ?? team?.active
        self.name = values["name"] as? String ?? team?.name
        self.teamApprovers = teamApprovers ?? team?.teamApprovers
        self.users = team?.users
    }
    
    init(team: Team? = nil, id: Int? = nil,
         active: Bool? = nil, emails: String? = nil,
         name: String? = nil, teamApprovers: [User]? = nil, users: [User]?) {
        self.id = id ?? team?.id
        self.emails = emails ?? team?.emails
        self.active = active ?? team?.active
        self.name = name ?? team?.name
        self.teamApprovers = teamApprovers ?? team?.teamApprovers
        self.users = users ?? team?.users
    }
    
    
}
