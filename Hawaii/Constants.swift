//
//  Constants.swift
//  Hawaii
//
//  Created by Server on 8/9/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct Constants {
    #if PRODUCTION
      static let baseUrl = "https://hawaii2.execom.eu"
    #else
      static let baseUrl = "http://nb077:8080"
    #endif
    //
    static let signin = baseUrl + "/signin"
    static let requests = baseUrl + "/requests"
    static let userRequests = requests + "/user"
    static let requestsToApprove = requests + "/approval"
    static let leaveTypes = baseUrl + "/leavetypes"
    static let getUser = baseUrl + "/users"
    static let publicHolidays = baseUrl + "/publicholidays"
    static let requestsByTeamByMonth = baseUrl + "/requests/team"
    static let requestsByMonth = baseUrl + "/requests/month"
    static let requestYears = baseUrl + "/requests/years/range"
    static let dateFormat = "yyyy-MM-dd"
    static let timeZone = "UTC"
}
