//
//  UsersResponse.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/4/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct UsersResponse {
    let success: Bool?
    let users: [User]?
    let maxUsers: Int?
    let error: Error?
    let message: String?
}
