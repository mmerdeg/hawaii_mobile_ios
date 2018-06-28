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
    
    let id : Int?
    let days: [Day]?
    let reason: String?
    let requestStatus: RequestStatus?
    let absence: Absence?
}

extension Request {
    init(request: Request? = nil, id: Int? = nil , reason: String? = nil, requestStatus: RequestStatus? = nil, abcence: Absence? = nil, days: [Day]? = nil) {
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
            return #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 0.2693707192)
        case .approved:
            return #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 0.2249839469)
        case .canceled:
             return UIColor.clear
        case .rejected:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.3000588613)
        }
    }
    
}

enum RequestType: Int {
    case vacation = 0
    case sick = 1
    case bonus = 2
    
}
