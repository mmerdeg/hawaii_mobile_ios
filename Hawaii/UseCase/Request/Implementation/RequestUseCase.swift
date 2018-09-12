//
//  RequestUseCase.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol RequestUseCaseProtocol {
    
    func getAll(completion: @escaping (RequestsResponse) -> Void)
    
    func add(request: Request, completion: @escaping (RequestResponse) -> Void)
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (RequestsResponse) -> Void)
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (RequestsResponse) -> Void)
    
    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (RequestsResponse) -> Void)
    
    func updateRequest(request: Request, completion: @escaping (RequestResponse) -> Void)
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (RequestsResponse) -> Void)
    
    func getAvailableRequestYears(completion: @escaping (YearsResponse) -> Void)
}

class RequestUseCase: RequestUseCaseProtocol {
    
    let entityRepository: RequestRepositoryProtocol!
    
    init(entityRepository: RequestRepositoryProtocol) {
        self.entityRepository = entityRepository
    }
    
    func getAll(completion: @escaping (RequestsResponse) -> Void) {
        entityRepository.getAll { requests in
            completion(requests)
        }
    }
    
    func add(request: Request, completion: @escaping (RequestResponse) -> Void) {
        entityRepository.add(request: request) {request in
            completion(request)
        }
    }
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (RequestsResponse) -> Void) {
        entityRepository.getAllByDate(from: from, toDate: toDate) { requests in
            completion(requests)
        }
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (RequestsResponse) -> Void) {
        entityRepository.getAllPendingForApprover(approver: approver) { requests in
            completion(requests)
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (RequestResponse) -> Void) {
        entityRepository.updateRequest(request: request) { request in
            completion(request)
        }
    }

    func getAllByTeam(from: Date, teamId: Int, completion: @escaping (RequestsResponse) -> Void) {
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
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (RequestsResponse) -> Void) {
        entityRepository.getAllForEmployee(byEmail: email) { requestsResponse in
            completion(requestsResponse)
        }
    }
    
    func getAvailableRequestYears(completion: @escaping (YearsResponse) -> Void) {
        entityRepository.getAvailableRequestYears { requestsResponse in
            completion(requestsResponse)
        }
    }
    
}
