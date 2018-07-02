//
//  LeaveRequest.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

struct Request {
    
    let id: Int?
    let days: [Day]?
    let reason: String?
    let requestStatus: RequestStatus?
    let absence: Absence?
}

extension Request {
    init(request: Request? = nil, id: Int? = nil ,
         reason: String? = nil, requestStatus: RequestStatus? = nil,
         abcence: Absence? = nil, days: [Day]? = nil) {
        self.id = id ?? request?.id
        self.reason = reason ?? request?.reason
        self.requestStatus = requestStatus ?? request?.requestStatus
        self.absence = abcence ?? request?.absence
        self.days = days ?? request?.days
    }
}

enum RequestStatus: String {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
    case canceled = "Canceled"
    
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
        }
    }
    
}
