import Foundation

struct Pageable: Codable {
    let offset: Int?
    let pageNumber: Int?
    let pageSize: Int?
    let paged: Bool?
    let unpaged: Bool?
    let sort: Sort?
}
