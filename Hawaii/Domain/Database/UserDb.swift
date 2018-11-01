import Foundation

struct UserDb: Codable {
    
    let id: Int?
    let teamId: Int?
    let leaveProfileId: Int?
    let fullName: String?
    let email: String?
    let userRole: String?
    let jobTitle: String?
    let active: Bool?
    let yearsOfService: Int?
}

extension UserDb {
    
    init(userDb: UserDb? = nil, id: Int? = nil, teamId: Int? = nil, leaveProfileId: Int? = nil,
         fullName: String? = nil, email: String? = nil, userRole: String? = nil,
         jobTitle: String? = nil, active: Bool? = nil, yearsOfService: Int? = nil) {
        self.id = id ?? userDb?.id
        self.teamId = teamId ?? userDb?.teamId
        self.leaveProfileId = leaveProfileId ?? userDb?.leaveProfileId
        self.fullName = fullName ?? userDb?.fullName
        self.email = email ?? userDb?.email
        self.userRole = userRole ?? userDb?.userRole
        self.jobTitle = jobTitle ?? userDb?.jobTitle
        self.active = active ?? userDb?.active
        self.yearsOfService = yearsOfService ?? userDb?.yearsOfService
    }
    
    init?(parameters: [String: Any]) {
        print(parameters)
        guard let id = parameters["id"] as? Int,
            let teamId = parameters["team_id"] as? Int,
            let leaveProfileId = parameters["leave_profile_id"] as? Int,
            let fullName = parameters["full_name"] as? String,
            let email = parameters["email"] as? String,
            let userRole = parameters["user_role"] as? String,
            let jobTitle = parameters["job_title"] as? String,
            let active = parameters["active"] as? Bool,
            let yearsOfService = parameters["years_of_service"] as? Int else {
                print("Error getting User data")
                return nil
        }
        self.id = id
        self.teamId = teamId
        self.leaveProfileId = leaveProfileId
        self.fullName = fullName
        self.email = email
        self.userRole = userRole
        self.jobTitle = jobTitle
        self.active = active
        self.yearsOfService = yearsOfService
    }
    
    init(entity: User) {
        self.id = entity.id
        self.teamId = entity.teamId
        self.leaveProfileId = entity.leaveProfileId
        self.fullName = entity.fullName
        self.email = entity.email
        self.userRole = entity.userRole
        self.jobTitle = entity.jobTitle
        self.active = entity.active
        self.yearsOfService = entity.yearsOfService
    }
    
    func toUser() -> User {
        return User(id: self.id, teamId: self.teamId, leaveProfileId: self.leaveProfileId,
                    fullName: self.fullName, email: self.email, userRole: self.userRole,
                    jobTitle: self.jobTitle, active: self.active, yearsOfService: self.yearsOfService, allowances: [])
    }
}
