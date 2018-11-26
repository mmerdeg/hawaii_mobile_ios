//
//  TeamsRepositoryProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TeamRepositoryProtocol: GenericRepositoryProtocol {
    
    func get(token: String, completion: @escaping (GenericResponse<[Team]>?) -> Void)
    
    func add(token: String, team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func update(token: String, team: Team, completion: @escaping (GenericResponse<Team>) -> Void)
    
    func delete(token: String, team: Team, completion: @escaping (GenericResponse<Any>?) -> Void)
    
}
