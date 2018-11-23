import Foundation

struct User: Codable, Hashable, CustomStringConvertible {
    
    let id: Int?
    let teamId: Int?
    let teamName: String?
    let leaveProfileId: Int?
    let fullName: String?
    let email: String?
    let userRole: String?
    let userPushTokens: [PushTokenDTO]?
    let jobTitle: String?
    let active: Bool?
    let yearsOfService: Int?
    let allowances: [Allowance]?

    
    var description : String { return fullName ?? ""}
    
}

extension User {
    init(user: User? = nil, id: Int? = nil, teamId: Int? = nil,
         teamName: String? = nil, leaveProfileId: Int? = nil, fullName: String? = nil,
         email: String? = nil, userRole: String? = nil, userPushTokens: [PushTokenDTO]? = nil, jobTitle: String? = nil,
         active: Bool? = nil, yearsOfService: Int? = nil, allowances: [Allowance]? = nil) {
        self.id = id ?? user?.id
        self.teamId = teamId ?? user?.teamId
        self.teamName = teamName ?? user?.teamName
        self.leaveProfileId = leaveProfileId ?? user?.leaveProfileId
        self.fullName = fullName ?? user?.fullName
        self.email = email ?? user?.email
        self.userRole = userRole ?? user?.userRole
        self.jobTitle = jobTitle ?? user?.jobTitle
        self.userPushTokens = userPushTokens ?? user?.userPushTokens
        self.active = active ?? user?.active
        self.yearsOfService = yearsOfService ?? user?.yearsOfService
        self.allowances = allowances ?? user?.allowances
    }
    
    init(user: User? = nil, values: [String: Any?], team: Team? = nil, leaveProfile: LeaveProfile? = nil) {
        self.id = user?.id
        self.teamId = team?.id ?? user?.teamId
        self.teamName = team?.name ?? user?.teamName
        self.leaveProfileId = leaveProfile?.id ?? user?.leaveProfileId
        self.fullName = values["fullName"] as? String ?? user?.fullName
        self.email = values["email"] as? String ?? user?.email
        self.userRole = values["userRole"] as? String ?? user?.userRole
        self.jobTitle = values["jobTitle"] as? String ?? user?.jobTitle
        self.active = values["active"] as? Bool ?? user?.active
        self.yearsOfService = values["yearsOfService"] as? Int ?? user?.yearsOfService
        self.allowances = user?.allowances
        self.userPushTokens = user?.userPushTokens
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
