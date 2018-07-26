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
    
}
