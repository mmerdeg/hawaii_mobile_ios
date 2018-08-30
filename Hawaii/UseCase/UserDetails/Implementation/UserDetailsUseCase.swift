//
//  UserDetailsUseCase.swift
//  Hawaii
//
//  Created by Server on 7/23/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol UserDetailsUseCaseProtocol {
    func getToken() -> String
    
    func setToken(token: String)
    
    func getEmail() -> String
    
    func setEmail(_ email: String)
}

class UserDetailsUseCase: UserDetailsUseCaseProtocol {
    
    let userDetailsRepository: UserDetailsRepositoryProtocol!
    
    init(userDetailsRepository: UserDetailsRepositoryProtocol) {
        self.userDetailsRepository = userDetailsRepository
    }
    
    func getToken() -> String {
        return userDetailsRepository.getToken()
    }
    
    func setToken(token: String) {
        userDetailsRepository.setToken(token: token)
    }
    
    func getEmail() -> String {
        return userDetailsRepository.getEmail()
    }
    
    func setEmail(_ email: String) {
        userDetailsRepository.setEmail(email)
    }
}