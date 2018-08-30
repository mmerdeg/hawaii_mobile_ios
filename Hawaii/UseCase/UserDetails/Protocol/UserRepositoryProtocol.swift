//
//  UserRepositoryProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol UserRepositoryProtocol {
    func getUser(completion: @escaping (User?) -> Void)
}
