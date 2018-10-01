//
//  UserDaoProtocol.swift
//  Hawaii
//
//  Created by Server on 9/28/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol UserDaoProtocol {
    
    func create(entity: User, completion: @escaping (Int) -> Void)
    
    func read(completion: @escaping (User?) -> Void)
}
