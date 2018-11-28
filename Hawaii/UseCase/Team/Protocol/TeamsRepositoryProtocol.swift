//
//  TeamsRepositoryProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TeamRepositoryProtocol: GenericRepositoryProtocol {
    
    func get(completion: @escaping (GenericResponse<[Team]>?) -> Void)
    
    func add(team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func update(team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func delete(team: Team, completion: @escaping (GenericResponse<Any>?) -> Void)
    
}
