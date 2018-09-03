//
//  RequestResponse.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/31/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct RequestResponse {
    let success: Bool?
    let requests: [Request]?
    let error: Error?
    let message: String?
}
