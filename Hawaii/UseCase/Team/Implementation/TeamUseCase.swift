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
    
    let userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    let teamRepository: TeamRepositoryProtocol?
    
    init(userDetailsUseCase: UserDetailsUseCaseProtocol,
         teamRepository: TeamRepositoryProtocol) {
        self.userDetailsUseCase = userDetailsUseCase
        self.teamRepository = teamRepository
    }
    
    func getTeams(completion: @escaping (GenericResponse<[Team]>?) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<[Team]>(success: false, item: nil, statusCode: 401,
                                               error: nil,
                                               message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        teamRepository?.getTeams(token: token, completion: { response in
            completion(response)
        })
    }
    
    func getToken() -> String? {
        return userDetailsUseCase?.getToken()
    }
}
