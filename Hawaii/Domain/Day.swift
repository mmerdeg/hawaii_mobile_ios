import Foundation

enum DurationType: String, Codable {
    
    case fullday = "FULL_DAY"
    case morning = "MORNING"
    case afternoon = "AFTERNOON"
    case afternoonFirst = "AFTERNOON-FIRST"
    case morningLast = "MORNING-LAST"
    case morningAndAfternoon = "MORNING-AFTERNOON"
    
    var description: String {
        switch self {
        case .fullday:
            return LocalizedKeys.Request.fullDay.localized()
        case .morning:
            return LocalizedKeys.Request.morning.localized()
        case .afternoon:
            return LocalizedKeys.Request.afternoon.localized()
        case .afternoonFirst:
            return LocalizedKeys.Request.afternoonFirst.localized()
        case .morningLast:
            return LocalizedKeys.Request.morningLast.localized()
        case .morningAndAfternoon:
            return LocalizedKeys.Request.morningAndAfternoon.localized()
        }
    }
    
}

struct Day: Codable {
    
    let id: Int?
    let date: Date?
    let duration: DurationType?
    let requestId: Int?
    
}

extension DurationType {
    
    init?(durationType: String) {
        switch durationType {
        case DurationType.fullday.description:
            self.init(rawValue: "FULL_DAY")
        case DurationType.morning.description:
            self.init(rawValue: "MORNING")
        case DurationType.afternoon.description:
            self.init(rawValue: "AFTERNOON")
        case DurationType.afternoonFirst.description:
            self.init(rawValue: "AFTERNOON-FIRST")
        case DurationType.morningLast.description:
            self.init(rawValue: "MORNING-LAST")
        case DurationType.morningAndAfternoon.description:
            self.init(rawValue: "MORNING-AFTERNOON")
        default:
            return nil
        }
    }
}
