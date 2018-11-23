//
//  LeaveProfileUseCase.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/22/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol LeaveProfileUseCaseProtocol {
    func get(completion: @escaping (GenericResponse<[LeaveProfile]>?) -> Void)
}

class LeaveProfileUseCase: LeaveProfileUseCaseProtocol {
    
    let userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    let leaveProfileRepository: LeaveProfileRepositoryProtocol?
    
    init(userDetailsUseCase: UserDetailsUseCaseProtocol,
         leaveProfileRepository: LeaveProfileRepositoryProtocol) {
        self.userDetailsUseCase = userDetailsUseCase
        self.leaveProfileRepository = leaveProfileRepository
    }
    
    func get(completion: @escaping (GenericResponse<[LeaveProfile]>?) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<[LeaveProfile]>(success: false, item: nil, statusCode: 401,
                                               error: nil,
                                               message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        leaveProfileRepository?.get(token: token, completion: { response in
            completion(response)
        })
    }
    
    func getToken() -> String? {
        return userDetailsUseCase?.getToken()
    }
}
