import Foundation

enum StatusType: String, Codable {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
    case deleted = "DELETED"
}

struct User: Codable, CustomStringConvertible {
    let id: Int?
    let teamId: Int?
    let teamName: String?
    let leaveProfileId: Int?
    let leaveProfileName: String?
    let fullName: String?
    let email: String?
    let userRole: String?
    let userPushTokens: [PushTokenDTO]?
    let jobTitle: String?
    let userStatusType: StatusType?
    let yearsOfService: Int?
    let allowances: [Allowance]?
    var description: String { return fullName ?? "" }
}

extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

extension User {
    init(user: User? = nil, id: Int? = nil, teamId: Int? = nil,
         teamName: String? = nil, leaveProfileId: Int? = nil, leaveProfileName: String? = nil, fullName: String? = nil,
         email: String? = nil, userRole: String? = nil, userPushTokens: [PushTokenDTO]? = nil, jobTitle: String? = nil,
         userStatusType: StatusType? = nil, yearsOfService: Int? = nil, allowances: [Allowance]? = nil) {
        self.id = id ?? user?.id
        self.teamId = teamId ?? user?.teamId
        self.teamName = teamName ?? user?.teamName
        self.leaveProfileId = leaveProfileId ?? user?.leaveProfileId
        self.fullName = fullName ?? user?.fullName
        self.email = email ?? user?.email
        self.userRole = userRole ?? user?.userRole
        self.jobTitle = jobTitle ?? user?.jobTitle
        self.userPushTokens = userPushTokens ?? user?.userPushTokens
        self.userStatusType = userStatusType ?? user?.userStatusType
        self.yearsOfService = yearsOfService ?? user?.yearsOfService
        self.allowances = allowances ?? user?.allowances
        self.leaveProfileName = leaveProfileName ?? user?.leaveProfileName
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
        self.yearsOfService = values["yearsOfService"] as? Int ?? user?.yearsOfService
        self.allowances = user?.allowances
        self.userPushTokens = user?.userPushTokens
        if let isActive = values["active"] as? Bool {
            self.userStatusType = isActive ? StatusType.active : StatusType.inactive
        } else {
            self.userStatusType = StatusType.active
        }
        self.leaveProfileName = leaveProfile?.name ?? user?.leaveProfileName
    }

}
