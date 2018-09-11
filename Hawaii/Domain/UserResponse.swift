//
//  UserResponse.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/4/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

struct UserResponse {
    let success: Bool?
    let user: User?
    let error: Error?
    let message: String?
}
