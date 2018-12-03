import Foundation
import UIKit

enum AbsenceType: String, Codable {
    case deducted = "DEDUCTED_LEAVE"
    case sick = "SICKNESS"
    case bonus = "BONUS_DAYS"
    case nonDecuted = "NON_DEDUCTED_LEAVE"
    
    var backgoundColor: UIColor? {
        switch self {
        case .deducted:
            return UIColor.pendingColor
        case .sick:
            return UIColor.sickColor
        case .bonus:
            return UIColor.lightGray
        case .nonDecuted:
            return UIColor.rejectedColor
        }
    }
}

struct Absence: Codable {
    let id: Int?
    let name: String?
    let absenceSubtype: String?
    let absenceType: String?
    let comment: String?
    let deleted: Bool?
    let iconUrl: String?
}
extension Absence {
    init(absence: Absence? = nil, id: Int? = nil, name: String? = nil, absenceSubtype: String? = nil ,
         absenceType: String? = nil, comment: String? = nil, deleted: Bool? = nil,
         iconUrl: String? = nil) {
        self.id = id ?? absence?.id
        self.name = name ?? absence?.name
        self.absenceSubtype = absenceSubtype ?? absence?.absenceSubtype
        self.absenceType = absenceType ?? absence?.absenceType
        self.comment = comment ?? absence?.comment
        self.deleted = deleted ?? absence?.deleted
        self.iconUrl = iconUrl ?? absence?.iconUrl
        
    }
}
