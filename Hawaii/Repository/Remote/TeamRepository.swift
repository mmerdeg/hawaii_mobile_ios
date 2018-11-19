//
//  TeamRepository.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import CodableAlamofire
import Alamofire

class TeamRepository: TeamRepositoryProtocol {
    
    let teamsUrl = ApiConstants.baseUrl + "/teams"
    
    func getTeams(token: String, completion: @escaping (GenericResponse<[Team]>?) -> Void) {
        guard let url = URL(string: teamsUrl) else {
            return
        }
        let activeKey = "active"
        let params = [activeKey: true]
        
        genericCodableRequest(value: [Team].self, url, parameters: params, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getHeaders(token: String) -> HTTPHeaders {
        return [ApiConstants.authHeader: token]
    }

}
