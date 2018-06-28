//
//  RequestUseCase.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol RequestUseCaseProtocol {
    
    func getAll(completion: @escaping ([Request])-> ())
    
}

class RequestUseCase: RequestUseCaseProtocol {
    
    let entityRepository: RequestRepositoryProtocol!
    
    init(entityRepository: RequestRepositoryProtocol) {
        self.entityRepository = entityRepository
    }
    
    func getAll(completion: @escaping ([Request]) -> ()) {
        entityRepository.getAll { requests in
            completion(requests)
        }
    }
    
}
