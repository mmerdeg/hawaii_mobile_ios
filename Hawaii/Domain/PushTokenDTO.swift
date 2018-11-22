//
//  PushTokenDTO.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/20/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

enum Platform: String, Codable {
    case iOS = "IOS"
}

struct PushTokenDTO: Codable {
    let pushToken: String?
    let name: String?
    let pushTokenId: Int?
    let platform: Platform?
}

extension PushTokenDTO {
    init(pushTokenDTO: PushTokenDTO? = nil, pushTokenId: Int? = nil, pushToken: String? = nil,
         name: String? = nil, platform: Platform? = nil) {
        self.pushTokenId = pushTokenId ?? pushTokenDTO?.pushTokenId
        self.pushToken = pushToken ?? pushTokenDTO?.pushToken
        self.name = name ?? pushTokenDTO?.name
        self.platform = platform ?? pushTokenDTO?.platform
    }
}
