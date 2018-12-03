import Foundation

struct UserDb: Codable {
    
    let id: Int?
    let teamId: Int?
    let teamName: String?
    let leaveProfileId: Int?
    let fullName: String?
    let email: String?
    let userRole: String?
    let jobTitle: String?
    let deleted: Bool?
    let yearsOfService: Int?
}

extension UserDb {
    
    init(userDb: UserDb? = nil, id: Int? = nil, teamId: Int? = nil, teamName: String? = nil, leaveProfileId: Int? = nil,
         fullName: String? = nil, email: String? = nil, userRole: String? = nil,
         jobTitle: String? = nil, deleted: Bool? = nil, yearsOfService: Int? = nil) {
        self.id = id ?? userDb?.id
        self.teamId = teamId ?? userDb?.teamId
        self.teamName = teamName ?? userDb?.teamName
        self.leaveProfileId = leaveProfileId ?? userDb?.leaveProfileId
        self.fullName = fullName ?? userDb?.fullName
        self.email = email ?? userDb?.email
        self.userRole = userRole ?? userDb?.userRole
        self.jobTitle = jobTitle ?? userDb?.jobTitle
        self.deleted = deleted ?? userDb?.deleted
        self.yearsOfService = yearsOfService ?? userDb?.yearsOfService
    }
    
    init?(parameters: [String: Any]) {
        guard let id = parameters["id"] as? Int,
            let teamId = parameters["team_id"] as? Int,
            let teamName = parameters["team_name"] as? String,
            let leaveProfileId = parameters["leave_profile_id"] as? Int,
            let fullName = parameters["full_name"] as? String,
            let email = parameters["email"] as? String,
            let userRole = parameters["user_role"] as? String,
            let jobTitle = parameters["job_title"] as? String,
            let deleted = parameters["deleted"] as? Bool,
            let yearsOfService = parameters["years_of_service"] as? Int else {
                return nil
        }
        self.id = id
        self.teamId = teamId
        self.teamName = teamName
        self.leaveProfileId = leaveProfileId
        self.fullName = fullName
        self.email = email
        self.userRole = userRole
        self.jobTitle = jobTitle
        self.deleted = deleted
        self.yearsOfService = yearsOfService
    }
    
    func toUser() -> User {
        return User(id: self.id, teamId: self.teamId, teamName: self.teamName, leaveProfileId: self.leaveProfileId,
                    fullName: self.fullName, email: self.email, userRole: self.userRole,
                    jobTitle: self.jobTitle, deleted: self.deleted, yearsOfService: self.yearsOfService, allowances: [])
    }
}
