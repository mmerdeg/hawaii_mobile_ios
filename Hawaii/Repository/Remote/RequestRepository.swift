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
    
    let authHeader = "X-AUTH-TOKEN"
    
    var requests: [Request]!
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        requests?.append(request)
        
        guard let url = URL(string: Constants.requests),
              let requestParameters = request.dictionary else {
                return
        }
        genericRequest(value: Request.self, url, method: .post,
                       parameters: requestParameters, encoding: JSONEncoding.default,
                       headers: getHeaders()) { response in
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
    
    func getAll(completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.userRequests) else {
            return
        }
        
        genericRequest(value: [Request].self, url, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.userRequests + "/\(id)") else {
            return
        }
        
        genericRequest(value: [Request].self, url, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        
        let formatter = getDateFormatter()
        let params = ["startDate": formatter.string(from: from),
                      "endDate": formatter.string(from: toDate)]
        
        guard let url = URL(string: Constants.userRequests + "/3/dates") else {
            return
        }
        
        genericRequest(value: [Request].self, url, parameters: params, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        guard let url = URL(string: Constants.requests),
              let requestParameters = request.dictionary else {
                return
        }
        genericRequest(value: Request.self, url, method: .put,
                       parameters: requestParameters,
                       encoding: JSONEncoding.default,
                       headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.requestsToApprove) else {
            return
        }
        
        genericRequest(value: [Request].self, url, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllByTeam(date: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        let urlString = Constants.requestsByTeamByMonth + "/\(teamId)/month"
        guard let url = URL(string: urlString) else {
            return
        }
        let formatter = getDateFormatter()
        let params = ["date": formatter.string(from: date)]
        
        genericRequest(value: [Request].self, url, parameters: params, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.userRequests) else {
            return
        }
        genericRequest(value: [Request].self, url, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllForAllEmployees(date: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: Constants.requestsByMonth) else {
            return
        }
        let formatter = getDateFormatter()
        let params = ["date": formatter.string(from: date)]
        
        genericRequest(value: [Request].self, url, parameters: params, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void) {
        guard let url = URL(string: Constants.requestYears) else {
            return
        }
        
        genericRequest(value: Year.self, url, method: .get, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getHeaders() -> HTTPHeaders {
        let token = userDetailsUseCase?.getToken()
        return [authHeader: token ?? ""]
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
