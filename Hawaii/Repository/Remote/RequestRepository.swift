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
    
    let requestsUrl = ApiConstants.baseUrl + "/requests"
    
    let allowancesUrl = ApiConstants.baseUrl  + "/allowances"
    
    let userRequestsUrl = ApiConstants.baseUrl + "/requests/user"
    
    let requestUrl = ApiConstants.baseUrl + "/requests"
    
    let requestsToApproveUrl = ApiConstants.baseUrl + "/requests/approval"
    
    let requestsByTeamByMonthUrl = ApiConstants.baseUrl + "/requests/team"
    
    let requestsByMonthUrl = ApiConstants.baseUrl + "/requests/month"
    
    func add(token: String, request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        requests?.append(request)
        
        guard let url = URL(string: requestsUrl),
              let requestParameters = request.dictionary else {
                return
        }
        genericCodableRequest(value: Request.self, url, method: .post,
                       parameters: requestParameters, encoding: JSONEncoding.default,
                       headers: getHeaders(token: token)) { response in
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
    
    func getBy(id: Int, token: String, completion: @escaping (GenericResponse<Request>) -> Void) {
        guard let url = URL(string: requestUrl + "/\(id)") else {
            return
        }
        genericCodableRequest(value: Request.self, url, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getAll(token: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: userRequestsUrl) else {
            return
        }
        genericCodableRequest(value: [Request].self, url, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getAllBy(token: String, id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: userRequestsUrl + "/\(id)") else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getAllByDate(token: String, userId: Int, from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        
        let formatter = getDateFormatter()
        
        let startDateKey = "startDate",
            endDateKey = "endDate"
        let params = [startDateKey: formatter.string(from: from),
                      endDateKey: formatter.string(from: toDate)]
        
        guard let url = URL(string: userRequestsUrl + "/\(userId)/dates") else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, parameters: params, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func updateRequest(token: String, request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        guard let url = URL(string: requestsUrl),
              let requestParameters = request.dictionary else {
                return
        }
        genericCodableRequest(value: Request.self, url, method: .put,
                       parameters: requestParameters,
                       encoding: JSONEncoding.default,
                       headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getAllPendingForApprover(token: String, approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: requestsToApproveUrl) else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getAllByTeam(token: String, date: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        let urlString = requestsByTeamByMonthUrl + "/\(teamId)/month"
        guard let url = URL(string: urlString) else {
            return
        }
        let formatter = getDateFormatter()
        let dateKey = "date"
        
        let params = [dateKey: formatter.string(from: date)]
        
        genericCodableRequest(value: [Request].self, url, parameters: params, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getAllForEmployee(token: String, byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: userRequestsUrl) else {
            return
        }
        genericCodableRequest(value: [Request].self, url, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getAllForAllEmployees(token: String, date: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: requestsByMonthUrl) else {
            return
        }
        let formatter = getDateFormatter()
        let dateKey = "date"
        
        let params = [dateKey: formatter.string(from: date)]
        
        genericCodableRequest(value: [Request].self, url, parameters: params, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getAvailableRequestYears(token: String, completion: @escaping (GenericResponse<Year>) -> Void) {
        guard let url = URL(string: ApiConstants.requestYears) else {
            return
        }
        
        genericCodableRequest(value: Year.self, url, method: .get, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func getHeaders(token: String) -> HTTPHeaders {
        let authHeader = "X-AUTH-TOKEN"
        return [authHeader: token]
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        let encoder = JSONEncoder()
        let formatter = RequestDateFormatter()
        
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
