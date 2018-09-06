//
//  UserRepositoryProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol UserRepositoryProtocol {
    func getUser(completion: @escaping (UserResponse?) -> Void)
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
}
