//
//  UserDetailsRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 7/23/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol UserDetailsRepositoryProtocol {
    func getToken(completion: @escaping (String) -> Void)
    
    func setToken(token: String)
}
