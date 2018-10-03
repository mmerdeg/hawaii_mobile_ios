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
    static let requestsByTeamByMonth = requests + "/team"
    static let requestsByMonth = requests + "/month"
    static let requestYears = requests + "/years/range"
    static let search = getUser + "/search"
    static let dateFormat = "yyyy-MM-dd"
    static let displayDateFormat = "dd.MM.yyyy."
    static let timeZone = "UTC"
    static let sqlExtension = "sql"
    static let dialogBackgroundAlpha = 0.85
}
