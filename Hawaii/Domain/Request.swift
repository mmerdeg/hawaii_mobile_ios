//
//  LeaveRequest.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

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
            return UIColor.clear
        case .rejected:
            return UIColor.rejectedColor
        case .cancelationPending:
            return UIColor.cancelationPendingColor
        }
    }
}

struct Request: Codable {
    let userId: Int?
    let absence: Absence?
    let requestStatus: RequestStatus?
    let reason: String?
    let approverId: Int?
    let days: [Day]?
    let id: Int?
}

extension Request {
    init(request: Request? = nil, approverId: Int? = nil, days: [Day]? = nil,
         reason: String? = nil, requestStatus: RequestStatus? = nil, absence: Absence? = nil,
         userId: Int? = nil, id: Int? = nil) {
        self.approverId = approverId ?? request?.approverId
        self.days = days ?? request?.days
        self.reason = reason ?? request?.reason
        self.requestStatus = requestStatus ?? request?.requestStatus
        self.userId = userId ?? request?.userId
        self.absence = absence ?? request?.absence
        self.id = id ?? request?.id
    }
}
