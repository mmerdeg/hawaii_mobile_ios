import Foundation

struct UsersResponse {
    let success: Bool?
    let users: [User]?
    let maxUsers: Int?
    let error: Error?
    let message: String?
}
