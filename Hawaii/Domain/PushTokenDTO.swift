//
//  PushTokenDTO.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/20/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

enum Platform: String, Codable, Hashable {
    case iOS = "IOS"
    case android = "ANDROID"
    var hashValue: Int {
        return self.rawValue.hashValue
    }
    
    var description: String {
        switch self {
        case .iOS:
            return "iOS"
        default:
            return "Android"
        }
    }
}

struct PushTokenDTO: Codable {
    let pushToken: String?
    let name: String?
    let pushTokenId: Int?
    let platform: Platform?
}

extension PushTokenDTO: Equatable {
    static func == (lhs: PushTokenDTO, rhs: PushTokenDTO) -> Bool {
        return lhs.pushTokenId == rhs.pushTokenId
    }
}

extension PushTokenDTO: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(pushTokenId)
    }
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
