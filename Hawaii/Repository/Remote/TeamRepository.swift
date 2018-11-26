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
    
    func get(token: String, completion: @escaping (GenericResponse<[Team]>?) -> Void) {
        guard let url = URL(string: teamsUrl) else {
            return
        }
        let activeKey = "active"
        let params = [activeKey: true]
        
        genericCodableRequest(value: [Team].self, url, parameters: params, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func add(token: String, team: Team, completion: @escaping (GenericResponse<Team>) -> Void) {
        guard let url = URL(string: teamsUrl),
            let userParameters = team.dictionary else {
                return
        }
        genericCodableRequest(value: Team.self, url, method: .post,
                              parameters: userParameters, encoding: JSONEncoding.default,
                              headers: getHeaders(token: token)) { response in
                                if response.statusCode == 416 {
                                    completion(GenericResponse<Team> (success: false, item: nil, statusCode: response.statusCode,
                                                                      error: response.error,
                                                                      message: LocalizedKeys.Api.tooManyDays.localized()))
                                } else if response.statusCode == 409 {
                                    completion(GenericResponse<Team> (success: false, item: nil, statusCode: response.statusCode,
                                                                      error: response.error,
                                                                      message: LocalizedKeys.Api.alreadyExists.localized()))
                                } else {
                                    completion(response)
                                }
        }
    }
    
    func update(token: String, team: Team, completion: @escaping (GenericResponse<Team>) -> Void) {
        guard let url = URL(string: teamsUrl),
            let requestParameters = team.dictionary else {
                return
        }
        genericCodableRequest(value: Team.self, url, method: .put,
                              parameters: requestParameters,
                              encoding: JSONEncoding.default,
                              headers: getHeaders(token: token)) { response in
                                completion(response)
        }
    }
    
    func delete(token: String, team: Team, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let id = team.id,
              let url = URL(string: teamsUrl + "/\(id)") else {
            return
        }

        genericJSONRequest(url, method: HTTPMethod.delete, headers: getHeaders(token: token)) { response in
                            completion(response)
        }
    }
    
    func getHeaders(token: String) -> HTTPHeaders {
        return [ApiConstants.authHeader: token]
    }

}
