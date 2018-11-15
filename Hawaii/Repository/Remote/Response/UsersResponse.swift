import Foundation

struct UsersResponse {
    let success: Bool?
    let users: [User]?
    let statusCode: Int?
    let maxUsers: Int?
    let error: Error?
    let message: String?
}
