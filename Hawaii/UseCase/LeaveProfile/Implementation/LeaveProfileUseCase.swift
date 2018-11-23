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
    
    let leaveProfileRepository: LeaveProfileRepositoryProtocol?
    
    init(leaveProfileRepository: LeaveProfileRepositoryProtocol) {
        self.leaveProfileRepository = leaveProfileRepository
    }
    
    func get(completion: @escaping (GenericResponse<[LeaveProfile]>?) -> Void) {
        leaveProfileRepository?.get(completion: { response in
            completion(response)
        })
    }
}
