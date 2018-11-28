//
//  LeaveProfileRepository.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/22/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import CodableAlamofire
import Alamofire

class LeaveProfileRepository: LeaveProfileRepositoryProtocol {
    
    let leaveProfileUrl = ApiConstants.baseUrl + "/leaveprofiles"
    
    func get(completion: @escaping (GenericResponse<[LeaveProfile]>?) -> Void) {
        guard let url = URL(string: leaveProfileUrl) else {
            return
        }
        
        genericCodableRequest(value: [LeaveProfile].self, url) { response in
            completion(response)
        }
    }
    
    func add(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<LeaveProfile>) -> Void) {
        guard let url = URL(string: leaveProfileUrl),
            let userParameters = leaveProfile.dictionary else {
                return
        }
        genericCodableRequest(value: LeaveProfile.self, url, method: .post,
                              parameters: userParameters, encoding: JSONEncoding.default) { response in
                                if response.statusCode == 416 {
                                    completion(GenericResponse<LeaveProfile> (success: false, item: nil, statusCode: response.statusCode,
                                                                      error: response.error,
                                                                      message: LocalizedKeys.Api.tooManyDays.localized()))
                                } else if response.statusCode == 409 {
                                    completion(GenericResponse<LeaveProfile> (success: false, item: nil, statusCode: response.statusCode,
                                                                      error: response.error,
                                                                      message: LocalizedKeys.Api.alreadyExists.localized()))
                                } else {
                                    completion(response)
                                }
        }
    }
    
    func update(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<LeaveProfile>) -> Void) {
        guard let url = URL(string: leaveProfileUrl),
            let requestParameters = leaveProfile.dictionary else {
                return
        }
        genericCodableRequest(value: LeaveProfile.self, url, method: .put,
                              parameters: requestParameters,
                              encoding: JSONEncoding.default) { response in
                                completion(response)
        }
    }
    
    func delete(leaveProfile: LeaveProfile, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let id = leaveProfile.id,
            let url = URL(string: leaveProfileUrl + "/\(id)") else {
                return
        }
        
        genericJSONRequest(url, method: HTTPMethod.delete) { response in
            completion(response)
        }
    }
}
