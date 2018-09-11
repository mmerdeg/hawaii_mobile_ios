//
//  PublicHolidayResponse.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/7/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct PublicHolidayResponse {
    let success: Bool?
    let holidays: [PublicHoliday]?
    let error: Error?
    let message: String?
}
