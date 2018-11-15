//
//  JwtExtenstion.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/15/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import JWTDecode

extension JWT {
    
    var expiration: Date? {
        return claim(name: "exp").date
    }
}
