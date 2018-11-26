//
//  TeamUseCase.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TeamUseCaseProtocol {
    func get(completion: @escaping (GenericResponse<[Team]>?) -> Void)
    
    func add(team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func update(team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func delete(team: Team, completion: @escaping (GenericResponse<Any>?) -> Void)
}

class TeamUseCase: TeamUseCaseProtocol {
    
    let userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    let teamRepository: TeamRepositoryProtocol?
    
    init(userDetailsUseCase: UserDetailsUseCaseProtocol,
         teamRepository: TeamRepositoryProtocol) {
        self.userDetailsUseCase = userDetailsUseCase
        self.teamRepository = teamRepository
    }
    
    func get(completion: @escaping (GenericResponse<[Team]>?) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<[Team]>(success: false, item: nil, statusCode: 401,
                                               error: nil,
                                               message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        teamRepository?.get(token: token, completion: { response in
            completion(response)
        })
    }
    
    func add(team: Team, completion: @escaping (GenericResponse<Team>) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<Team> (success: false, item: nil, statusCode: 401,
                                                       error: nil,
                                                       message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        teamRepository?.add(token: token, team: team, completion: { response in
            completion(response)
        })
    }
    
    func update(team: Team, completion: @escaping (GenericResponse<Team>) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<Team> (success: false, item: nil, statusCode: 401,
                                                       error: nil,
                                                       message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        teamRepository?.update(token: token, team: team, completion: { response in
            completion(response)
        })
    }
    
    func delete(team: Team, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                             error: nil,
                                             message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        teamRepository?.delete(token: token, team: team, completion: { response in
            completion(response)
        })
    }
    
    func getToken() -> String? {
        return userDetailsUseCase?.getToken()
    }
}
