import Foundation

struct PublicHoliday: Codable {
    let id: Int?
    let active: Bool?
    let date: Date?
    let name: String?
}

extension PublicHoliday {
    
    init(publicHoliday: PublicHoliday? = nil, values: [String: Any?]) {
        self.id = publicHoliday?.id
        self.date = values["date"] as? Date ?? publicHoliday?.date
        self.active = values["active"] as? Bool ?? publicHoliday?.active
        self.name = values["name"] as? String ?? publicHoliday?.name
    }
    
    static func == (lhs: PublicHoliday, rhs: PublicHoliday) -> Bool {
        return lhs.id == rhs.id
    }
}
