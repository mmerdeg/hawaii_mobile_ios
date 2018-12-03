//
//  TeamUseCase.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TeamUseCase {
    func get(completion: @escaping (GenericResponse<[Team]>?) -> Void)
    
    func add(team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func update(team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func delete(team: Team, completion: @escaping (GenericResponse<Any>?) -> Void)
}

class TeamUseCaseImplementation: TeamUseCase {
    
    let teamRepository: TeamRepository?
    
    init(teamRepository: TeamRepository) {
        self.teamRepository = teamRepository
    }
    
    func get(completion: @escaping (GenericResponse<[Team]>?) -> Void) {
        teamRepository?.get(completion: { response in
            completion(response)
        })
    }
    
    func add(team: Team, completion: @escaping (GenericResponse<Team>) -> Void) {
        teamRepository?.add(team: team, completion: { response in
            completion(response)
        })
    }
    
    func update(team: Team, completion: @escaping (GenericResponse<Team>) -> Void) {
        teamRepository?.update(team: team, completion: { response in
            completion(response)
        })
    }
    
    func delete(team: Team, completion: @escaping (GenericResponse<Any>?) -> Void) {
        teamRepository?.delete(team: team, completion: { response in
            completion(response)
        })
    }
}
