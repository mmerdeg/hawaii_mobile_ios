//
//  RequestRepository.swift
//  Hawaii
//
//  Created by Server on 6/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import CodableAlamofire
import Alamofire

class RequestRepository: RequestRepositoryProtocol {
    
    var requests: [Request]!
    
    func add(token: HTTPHeaders, request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        requests?.append(request)
        
        guard let url = URL(string: Constants.requests),
              let requestParameters = request.dictionary else {
                return
        }
        genericCodableRequest(value: Request.self, url, method: .post,
                       parameters: requestParameters, encoding: JSONEncoding.default,
                       headers: token) { response in
            if response.statusCode == 416 {
                completion(GenericResponse<Request> (success: false, item: nil, statusCode: response.statusCode,
                                               error: response.error,
                                               message: "Invalid request, too many days selected"))
            } else if response.statusCode == 409 {
                completion(GenericResponse<Request> (success: false, item: nil, statusCode: response.statusCode,
                                               error: response.error,
                                               message: "Alredy exists in database"))
            } else {
                completion(response)
            }
        }
    
    }
    
    func getAll(token: HTTPHeaders, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.userRequests) else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, headers: token) { response in
            completion(response)
        }
    }
    
    func getAllBy(token: HTTPHeaders, id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.userRequests + "/\(id)") else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, headers: token) { response in
            completion(response)
        }
    }
    
    func getAllByDate(token: HTTPHeaders, userId: Int, from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        
        let formatter = getDateFormatter()
        let params = ["startDate": formatter.string(from: from),
                      "endDate": formatter.string(from: toDate)]
        
        guard let url = URL(string: Constants.userRequests + "/\(userId)/dates") else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, parameters: params, headers: token) { response in
            completion(response)
        }
    }
    
    func updateRequest(token: HTTPHeaders, request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        guard let url = URL(string: Constants.requests),
              let requestParameters = request.dictionary else {
                return
        }
        genericCodableRequest(value: Request.self, url, method: .put,
                       parameters: requestParameters,
                       encoding: JSONEncoding.default,
                       headers: token) { response in
            completion(response)
        }
    }
    
    func getAllPendingForApprover(token: HTTPHeaders, approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.requestsToApprove) else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, headers: token) { response in
            completion(response)
        }
    }
    
    func getAllByTeam(token: HTTPHeaders, date: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        let urlString = Constants.requestsByTeamByMonth + "/\(teamId)/month"
        guard let url = URL(string: urlString) else {
            return
        }
        let formatter = getDateFormatter()
        let params = ["date": formatter.string(from: date)]
        
        genericCodableRequest(value: [Request].self, url, parameters: params, headers: token) { response in
            completion(response)
        }
    }
    
    func getAllForEmployee(token: HTTPHeaders, byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.userRequests) else {
            return
        }
        genericCodableRequest(value: [Request].self, url, headers: token) { response in
            completion(response)
        }
    }
    
    func getAllForAllEmployees(token: HTTPHeaders, date: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.requestsByMonth) else {
            return
        }
        let formatter = getDateFormatter()
        let params = ["date": formatter.string(from: date)]
        
        genericCodableRequest(value: [Request].self, url, parameters: params, headers: token) { response in
            completion(response)
        }
    }
    
    func getAvailableRequestYears(token: HTTPHeaders, completion: @escaping (GenericResponse<Year>) -> Void) {
        guard let url = URL(string: Constants.requestYears) else {
            return
        }
        
        genericCodableRequest(value: Year.self, url, method: .get, headers: token) { response in
            completion(response)
        }
    }
    
}

extension Encodable {
    var dictionary: [String: Any]? {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        encoder.dateEncodingStrategy = .formatted(formatter)
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
