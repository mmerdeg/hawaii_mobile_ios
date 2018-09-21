//
//  YearResponse.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/11/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct YearResponse {
    let success: Bool?
    let year: Year?
    let error: Error?
    let message: String?
}
