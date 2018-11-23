//
//  TeamUseCase.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TeamUseCaseProtocol {
    func getTeams(completion: @escaping (GenericResponse<[Team]>?) -> Void)
}

class TeamUseCase: TeamUseCaseProtocol {
    
    let teamRepository: TeamRepositoryProtocol?
    
    init(teamRepository: TeamRepositoryProtocol) {
        self.teamRepository = teamRepository
    }
    
    func getTeams(completion: @escaping (GenericResponse<[Team]>?) -> Void) {
        teamRepository?.getTeams(completion: { response in
            completion(response)
        })
    }
}
