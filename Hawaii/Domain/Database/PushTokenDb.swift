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
}

extension PushTokenDb {
    init(pushTokenDTO: PushTokenDb? = nil, pushTokenId: Int? = nil, pushToken: String? = nil,
         name: String? = nil, platform: Platform? = nil) {
        self.pushTokenId = pushTokenId ?? pushTokenDTO?.pushTokenId
        self.pushToken = pushToken ?? pushTokenDTO?.pushToken
        self.name = name ?? pushTokenDTO?.name
        self.platform = platform ?? pushTokenDTO?.platform
    }
    
    init?(parameters: [String: Any]) {
        print(parameters)
        guard let id = parameters["id"] as? Int,
            let name = parameters["name"] as? String,
            let platform = parameters["platform"] as? String,
            let pushToken = parameters["push_token"] as? String else {
                print("Error getting User data")
                return nil
        }
        self.pushTokenId = id
        self.name = name
        self.platform = Platform(rawValue: platform)
        self.pushToken = pushToken
    }
    
    init(entity: PushTokenDTO) {
        self.pushTokenId = entity.pushTokenId
        self.name = entity.name
        self.platform = entity.platform
        self.pushToken = entity.pushToken
    }
    
    func toPushToken() -> PushTokenDTO {
        return PushTokenDTO(pushTokenId: self.pushTokenId, pushToken: self.pushToken, name: self.name, platform: self.platform)
    }
}
