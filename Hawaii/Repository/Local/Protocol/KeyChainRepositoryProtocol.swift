//
//  KeyChainRepositoryProtocol.swift
//  Hawaii
//
//  Created by Server on 10/19/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol KeyChainRepositoryProtocol {
    
    func getItem(key: String) -> String
    
    func setItem(key: String, value: String)
    
    func removeItem(key: String)
}
