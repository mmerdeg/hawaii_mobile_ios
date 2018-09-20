//
//  UserDetailsRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 7/23/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol UserDetailsRepositoryProtocol {
    func getToken() -> String
    
    func setToken(token: String)
    
    func getEmail() -> String
    
    func setEmail(_ email: String)
    
    func getLoadMore() -> Bool
    
    func setLoadMore(_ loadMore: Bool)
}
