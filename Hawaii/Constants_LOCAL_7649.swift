//
//  Constants.swift
//  Hawaii
//
//  Created by Server on 8/9/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct Constants {
    static let baseUrl = "https://hawaii2.execom.eu"
    static let signin = baseUrl + "/signin"
    static let requests = baseUrl + "/requests"
    static let userRequests = requests + "/user"
    static let requestsToApprove = requests + "/approval"
    static let leaveTypes = baseUrl + "/leavetypes"
    static let getUser = baseUrl + "/users"
    static let dateFormat = "yyyy-MM-dd"
    static let timeZone = "UTC"
    static let userId = 2
}
