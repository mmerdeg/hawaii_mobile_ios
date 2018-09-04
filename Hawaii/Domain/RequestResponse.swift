//
//  RequestResponse.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/3/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct RequestResponse {
    let success: Bool?
    let request: Request?
    let error: Error?
    let message: String?
}
