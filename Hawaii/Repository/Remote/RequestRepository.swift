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
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    let requestsUrl = ApiConstants.baseUrl + "/requests"
    
    let allowancesUrl = ApiConstants.baseUrl  + "/allowances"
    
    let userRequestsUrl = ApiConstants.baseUrl + "/requests/user"
    
    let requestsToApproveUrl = ApiConstants.baseUrl + "/requests/approval"
    
    let requestsByTeamByMonthUrl = ApiConstants.baseUrl + "/requests/team"
    
    let requestsByMonthUrl = ApiConstants.baseUrl + "/requests/month"
    
    init(userDetailsUseCase: UserDetailsUseCaseProtocol) {
        self.userDetailsUseCase = userDetailsUseCase
    }
    
    func add(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        requests?.append(request)
        
        guard let url = URL(string: requestsUrl),
              let requestParameters = request.dictionary else {
                return
        }
        genericCodableRequest(value: Request.self, url, method: .post,
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
        guard let url = URL(string: userRequestsUrl) else {
            return
        }
        genericCodableRequest(value: [Request].self, url, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllBy(id: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: userRequestsUrl + "/\(id)") else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllByDate(userId: Int, from: Date, toDate: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        
        let formatter = getDateFormatter()
        
        let startDateKey = "startDate",
            endDateKey = "endDate"
        let params = [startDateKey: formatter.string(from: from),
                      endDateKey: formatter.string(from: toDate)]
        
        guard let url = URL(string: userRequestsUrl + "/\(userId)/dates") else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, parameters: params, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        guard let url = URL(string: requestsUrl),
              let requestParameters = request.dictionary else {
                return
        }
        genericCodableRequest(value: Request.self, url, method: .put,
                       parameters: requestParameters,
                       encoding: JSONEncoding.default,
                       headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: requestsToApproveUrl) else {
            return
        }
        
        genericCodableRequest(value: [Request].self, url, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllByTeam(date: Date, teamId: Int, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        let urlString = requestsByTeamByMonthUrl + "/\(teamId)/month"
        guard let url = URL(string: urlString) else {
            return
        }
        let formatter = getDateFormatter()
        let dateKey = "date"
        
        let params = [dateKey: formatter.string(from: date)]
        
        genericCodableRequest(value: [Request].self, url, parameters: params, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: userRequestsUrl) else {
            return
        }
        genericCodableRequest(value: [Request].self, url, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAllForAllEmployees(date: Date, completion: @escaping (GenericResponse<[Request]>) -> Void) {
        guard let url = URL(string: requestsByMonthUrl) else {
            return
        }
        let formatter = getDateFormatter()
        let dateKey = "date"
        
        let params = [dateKey: formatter.string(from: date)]
        
        genericCodableRequest(value: [Request].self, url, parameters: params, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getAvailableRequestYears(completion: @escaping (GenericResponse<Year>) -> Void) {
        guard let url = URL(string: ApiConstants.requestYears) else {
            return
        }
        
        genericCodableRequest(value: Year.self, url, method: .get, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func getHeaders() -> HTTPHeaders {
        let authHeader = "X-AUTH-TOKEN"
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
