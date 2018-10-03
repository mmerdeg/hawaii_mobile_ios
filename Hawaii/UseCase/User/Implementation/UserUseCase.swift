//
//  UserUseCase.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol UserUseCaseProtocol {
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func createUser(entity: User, completion: @escaping (Int) -> Void)
    
    func readUser(completion: @escaping (User?) -> Void)
}

class UserUseCase: UserUseCaseProtocol {
    
    let userRepository: UserRepositoryProtocol?
    
    let userDao: UserDaoProtocol?
    
    init(userRepository: UserRepositoryProtocol, userDao: UserDaoProtocol) {
        self.userRepository = userRepository
        self.userDao = userDao
    }
    
    func createUser(entity: User, completion: @escaping (Int) -> Void) {
        userDao?.create(entity: entity) { id in
            completion(id)
        }
    }
    
    func readUser(completion: @escaping (User?) -> Void) {
        userDao?.read { user in
            completion(user)
        }
    }
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void) {
        userRepository?.getUsersByParameter(parameter: parameter, page: page, numberOfItems: numberOfItems) { response in
            completion(response)
        }
    }
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void) {
        userRepository?.getUser { response in
            completion(response)
        }
    }
}
