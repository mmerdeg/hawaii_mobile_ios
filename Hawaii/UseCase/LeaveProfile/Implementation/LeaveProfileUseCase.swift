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
    
    func add(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<LeaveProfile>) -> Void)
    
    func update(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<LeaveProfile>) -> Void)
    
    func delete(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<Any>?) -> Void)
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
    
    func add(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<LeaveProfile>) -> Void) {
        leaveProfileRepository?.add(leaveProfile: leaveProfile, completion: { response in
            completion(response)
        })
    }
    
    func update(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<LeaveProfile>) -> Void) {
        leaveProfileRepository?.update(leaveProfile: leaveProfile, completion: { response in
            completion(response)
        })
    }
    
    func delete(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<Any>?) -> Void) {
        leaveProfileRepository?.delete(leaveProfile: leaveProfile, completion: { response in
            completion(response)
        })
    }
}
