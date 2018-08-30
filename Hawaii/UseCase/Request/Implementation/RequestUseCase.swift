//
//  RequestUseCase.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol RequestUseCaseProtocol {
    
    func getAll(completion: @escaping ([Request]) -> Void)
    
    func add(request: Request, completion: @escaping (Request) -> Void)
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping ([Request]) -> Void)
    
    func getAllPendingForApprover(approver: Int, completion: @escaping ([Request]) -> Void)
    
    func getAllByTeam(from: Date, teamId: Int, completion: @escaping ([Request]) -> Void)
    
    func updateRequest(request: Request, completion: @escaping (Request) -> Void)
}

class RequestUseCase: RequestUseCaseProtocol {
    
    let entityRepository: RequestRepositoryProtocol!
    
    init(entityRepository: RequestRepositoryProtocol) {
        self.entityRepository = entityRepository
    }
    
    func getAll(completion: @escaping ([Request]) -> Void) {
        entityRepository.getAll { requests in
            completion(requests)
        }
    }
    
    func add(request: Request, completion: @escaping (Request) -> Void) {
        entityRepository.add(request: request) {request in
            completion(request)
        }
    }
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping ([Request]) -> Void) {
        entityRepository.getAllByDate(from: from, toDate: toDate) { requests in
            completion(requests)
        }
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping ([Request]) -> Void) {
        entityRepository.getAllPendingForApprover(approver: approver) { requests in
            completion(requests)
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (Request) -> Void) {
        entityRepository.updateRequest(request: request) { request in
            completion(request)
        }
    }

    func getAllByTeam(from: Date, teamId: Int, completion: @escaping ([Request]) -> Void) {
        if teamId != -1 {
             entityRepository.getAllByTeam(date: from, teamId: teamId) { requests in
                completion(requests)
             }
        } else {
            entityRepository.getAllForAllEmployees(date: from) { requests in
                completion(requests)
            }
        }
    }

}
