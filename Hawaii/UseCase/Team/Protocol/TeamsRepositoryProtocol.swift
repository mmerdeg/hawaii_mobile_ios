//
//  TeamsRepositoryProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

protocol TeamRepositoryProtocol: GenericRepositoryProtocol {
    
    func getTeams(token: String, completion: @escaping (GenericResponse<[Team]>?) -> Void)
    
}
