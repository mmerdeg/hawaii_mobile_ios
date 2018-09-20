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
    let emailKey = "email"
    let loadMoreKey = "loadMore"
    
    func getToken() -> String {
        var token = ""
        if preferences.object(forKey: tokenKey) != nil {
            guard let authToken = preferences.string(forKey: tokenKey) else {
                return ""
            }
            token = authToken
        }
        return token
    }
    
    func setToken(token: String) {
        preferences.set(token, forKey: tokenKey)
        preferences.synchronize()
    }
    
    func getEmail() -> String {
        var email = ""
        if preferences.object(forKey: emailKey) != nil {
            guard let emailValue = preferences.string(forKey: emailKey) else {
                return ""
            }
            email = emailValue
        }
        return email
    }
    
    func setEmail(_ email: String) {
        preferences.set(email, forKey: emailKey)
        preferences.synchronize()
    }
    
    func getLoadMore() -> Bool {
        var loadMore = false
        if preferences.object(forKey: loadMoreKey) != nil {
            loadMore = preferences.bool(forKey: loadMoreKey)
        }
        return loadMore
    }
    
    func setLoadMore(_ loadMore: Bool) {
        preferences.set(loadMore, forKey: loadMoreKey)
        preferences.synchronize()
    }
}
