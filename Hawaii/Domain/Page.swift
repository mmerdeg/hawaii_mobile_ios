import Foundation

struct Page: Codable {
    let content: [User]?
    let first: Bool?
    let last: Bool?
    let number: Int?
    let numberOfElements: Int?
    let pageable: Pageable?
    let size: Int?
    let sort: Sort?
    let totalElements: Int?
    let totalPages: Int?
}
