import Foundation
import UIKit

enum RequestStatus: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case rejected = "REJECTED"
    case canceled = "CANCELED"
    case cancelationPending = "CANCELLATION_PENDING"
    
    var backgoundColor: UIColor? {
        switch self {
        case .pending:
            return UIColor.pendingColor
        case .approved:
            return UIColor.approvedColor
        case .canceled:
            return UIColor.lightGray
        case .rejected:
            return UIColor.rejectedColor
        case .cancelationPending:
            return UIColor.cancelationPendingColor
        }
    }
    
    var description: String? {
        switch self {
        case .pending:
            return LocalizedKeys.Request.pending.localized()
        case .approved:
            return LocalizedKeys.Request.approved.localized()
        case .canceled:
            return LocalizedKeys.Request.canceled.localized()
        case .rejected:
            return LocalizedKeys.Request.rejected.localized()
        case .cancelationPending:
            return LocalizedKeys.Request.cancelationPending.localized()
        }
    }
}

struct Request: Codable, Equatable {
    
    let user: User?
    let absence: Absence?
    let requestStatus: RequestStatus?
    let reason: String?
    let approverId: Int?
    let days: [Day]?
    let id: Int?
    let submissionTime: String?
    
}

extension Request {
    init(request: Request? = nil, approverId: Int? = nil, days: [Day]? = nil,
         reason: String? = nil, requestStatus: RequestStatus? = nil, absence: Absence? = nil,
         user: User? = nil, id: Int? = nil, submissionTime: String? = nil) {
        self.approverId = approverId ?? request?.approverId
        self.days = days ?? request?.days
        self.reason = reason ?? request?.reason
        self.requestStatus = requestStatus ?? request?.requestStatus
        self.user = user ?? request?.user
        self.absence = absence ?? request?.absence
        self.id = id ?? request?.id
        self.submissionTime = submissionTime ?? request?.submissionTime
    }

    static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.id == rhs.id
    }
}
