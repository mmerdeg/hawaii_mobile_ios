//
//  UserDetailsRepository.swift
//  Hawaii
//
//  Created by Server on 7/23/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class UserDetailsRepository: UserDetailsRepositoryProtocol {
    
    let preferences = UserDefaults.standard
    
    let tokenKey = "token"
    
    func getToken(completion: @escaping (String) -> Void) {
        if preferences.object(forKey: tokenKey) != nil {
            guard let token = preferences.string(forKey: tokenKey) else {
                return
            }
            completion(token)
        }
    }
    
    func setToken(token: String) {
//        let preferences = UserDefaults.standard
//        
//        let currentLevel = ...
//        let currentLevelKey = "currentLevel"
//        preferences.set(currentLevel, forKey: currentLevelKey)
//        
//        preferences.synchronize()
    }
}
