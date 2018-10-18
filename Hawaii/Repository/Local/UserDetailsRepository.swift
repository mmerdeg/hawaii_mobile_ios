//
//  UserDetailsRepository.swift
//  Hawaii
//
//  Created by Server on 7/23/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class UserDetailsRepository: UserDetailsRepositoryProtocol {
    
    var keyChainRepository: KeyChainRepository?
    
    let userDefaults = UserDefaults.standard
    
    let tokenKey = "token"
    
    let emailKey = "email"
    
    let loadMoreKey = "loadMore"
    
    init(keyChainRepository: KeyChainRepository) {
        self.keyChainRepository = keyChainRepository
    }
    
    func getToken() -> String? {
        return keyChainRepository?.getItem(key: tokenKey)
    }
    
    func setToken(token: String) {
        keyChainRepository?.setItem(key: tokenKey, value: token)
    }
    
    func removeToken() {
        keyChainRepository?.removeItem(key: tokenKey)
    }
    
    func getEmail() -> String? {
        return keyChainRepository?.getItem(key: emailKey)
    }
    
    func setEmail(_ email: String) {
        keyChainRepository?.setItem(key: emailKey, value: email)
    }
    
    func removeEmail() {
        keyChainRepository?.removeItem(key: emailKey)
    }
    
    func getLoadMore() -> Bool {
        var loadMore = false
        if userDefaults.object(forKey: loadMoreKey) != nil {
            loadMore = userDefaults.bool(forKey: loadMoreKey)
        }
        return loadMore
    }
    
    func setLoadMore(_ loadMore: Bool) {
        userDefaults.set(loadMore, forKey: loadMoreKey)
        userDefaults.synchronize()
    }
}
