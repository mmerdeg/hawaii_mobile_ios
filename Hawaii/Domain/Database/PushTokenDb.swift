//
//  TokenDb.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation


struct PushTokenDb: Codable {
    let pushToken: String?
    let name: String?
    let pushTokenId: Int?
    let platform: Platform?
    let userId: Int?
}

extension PushTokenDb {
    init(pushTokenDb: PushTokenDb? = nil, pushTokenId: Int? = nil, pushToken: String? = nil,
         name: String? = nil, platform: Platform? = nil, userId: Int? = nil) {
        self.pushTokenId = pushTokenId ?? pushTokenDb?.pushTokenId
        self.pushToken = pushToken ?? pushTokenDb?.pushToken
        self.name = name ?? pushTokenDb?.name
        self.platform = platform ?? pushTokenDb?.platform
        self.userId = userId ?? pushTokenDb?.userId
    }
    
    init?(parameters: [String: Any]) {
        print(parameters)
        guard let id = parameters["id"] as? Int,
            let name = parameters["name"] as? String,
            let platform = parameters["platform"] as? String,
            let pushToken = parameters["push_token"] as? String,
            let userId = parameters["user_id"] as? Int else {
                print("Error getting User data")
                return nil
        }
        self.pushTokenId = id
        self.name = name
        self.platform = Platform(rawValue: platform)
        self.pushToken = pushToken
        self.userId = userId
    }
    
    func toPushToken() -> PushTokenDTO {
        return PushTokenDTO(pushTokenId: self.pushTokenId, pushToken: self.pushToken, name: self.name, platform: self.platform)
    }
}
