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
    
    let dateFormat = "yyyy-MM-dd"
    
    let timeZone = "UTC"
    
    var requests: [Request]!
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    func add(request: Request, completion: @escaping (Request) -> Void) {
        requests?.append(request)
        
        guard let encodedRequest = try? getEncoder().encode(request),
            let url = URL(string: Constants.requests),
            let parameters = try? JSONSerialization.jsonObject(with: encodedRequest, options: []) as? [String: Any],
            let requestParameters = parameters else {
                return
            }
        
        Alamofire.request(url, method: HTTPMethod.post, parameters: requestParameters, encoding: JSONEncoding.default,
                          headers: getHeaders()).responseString { response in
            print(response.error ?? "")
            completion(request)
        }
    }
    
    func getAll(completion: @escaping ([Request]) -> Void) {
        
        guard let url = URL(string: Constants.userRequests + "/3") else {
            return
        }
        
        Alamofire.request(url, method: HTTPMethod.get, headers: getHeaders())
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                print(response)
                completion(response.result.value ?? [])
            }
    }
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping ([Request]) -> Void) {
        
        let formatter = getDateFormatter()
        let params = ["startDate": formatter.string(from: from),
                      "endDate": formatter.string(from: toDate)]
        
        guard let url = URL(string: Constants.userRequests + "/3/dates") else {
            return
        }
        
        Alamofire.request(url, method: HTTPMethod.get, parameters: params, headers: getHeaders())
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                print(response)
                completion(response.result.value ?? [])
            }
    }
    
    func updateRequest(request: Request, completion: @escaping (Request) -> Void) {
        
        guard let encodedData = try? getEncoder().encode(request),
            let url = URL(string: Constants.requests),
            let parameters = try? JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any],
            let requestParameters = parameters else {
                return
        }
        
        Alamofire.request(url, method: HTTPMethod.put, parameters: requestParameters, encoding: JSONEncoding.default,
                          headers: getHeaders()).responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<Request>) in
            print(response)
            completion(response.result.value ?? request)
        }
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping ([Request]) -> Void) {
        guard let url = URL(string: Constants.requestsToApprove) else {
            return
        }
        
        Alamofire.request(url, headers: getHeaders())
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
            print(response)
            completion(response.result.value ?? [])
            }
    }
    
    func getAllByTeam(date: Date, teamId: Int, completion: @escaping ([Request]) -> Void) {
        guard let url = URL(string: Constants.requestsToApprove) else {
            return
        }
        
        Alamofire.request(url, headers: getHeaders())
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                print(response)
                completion(response.result.value ?? [])
            }
    }
    
    func getAllForAllEmployees(date: Date, completion: @escaping ([Request]) -> Void) {
        guard let url = URL(string: Constants.requestsToApprove) else {
            return
        }
        
        Alamofire.request(url, headers: getHeaders())
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                print(response)
                completion(response.result.value ?? [])
            }
    }
    
    func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getDateFormatter())
        return decoder
    }
    
    func getEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(getDateFormatter())
        return encoder
    }
    
    func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone(abbreviation: timeZone)
        return formatter
    }
    
    func getHeaders() -> HTTPHeaders {
        let token = userDetailsUseCase?.getToken()
        return [authHeader: token ?? ""]
    }
}
