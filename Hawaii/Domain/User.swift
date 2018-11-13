import Foundation

struct User: Codable {
    
    let id: Int?
    let teamId: Int?
    let teamName: String?
    let leaveProfileId: Int?
    let fullName: String?
    let email: String?
    let userRole: String?
    let jobTitle: String?
    let active: Bool?
    let yearsOfService: Int?
    let allowances: [Allowance]?
    
}
