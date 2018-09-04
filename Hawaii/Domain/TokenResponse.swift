//
//  TokenResponse.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/4/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct TokenResponse {
    let success: Bool?
    let token: String?
    let error: Error?
    let message: String?
}
