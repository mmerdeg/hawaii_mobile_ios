//
//  ApiConstants.swift
//  Hawaii
//
//  Created by Server on 10/17/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class ApiConstants {
    
    #if PRODUCTION
    static let baseUrl = "https://hawaii2.execom.eu"
    static let requestYears = baseUrl + "/requests" + "/years/range"
    #else
    static let baseUrl = "http://10.0.5.142:8080"
    static let requestYears = baseUrl  + "/allowances" + "/years/range"
    #endif

    
    static let sqlExtension = "sql"
    static let dialogBackgroundAlpha = 0.85
    static let maxTimeElapsed = 15
}
