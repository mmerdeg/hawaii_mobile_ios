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
    
    func add(request: Request, completion: @escaping (RequestResponse) -> Void) {
        requests?.append(request)
        
        guard let url = URL(string: Constants.requests),
              let requestParameters = request.dictionary else {
                return
        }
        print(requestParameters)
        Alamofire.request(url, method: HTTPMethod.post, parameters: requestParameters, encoding: JSONEncoding.default,
                          headers: getHeaders()).validate().responseString { response in
                            switch response.result {
                            case .success:
                                print("Validation Successful")
                                completion(RequestResponse(success: true, request: request, error: nil, message: nil))
                            case .failure(let error):
                                print(error)
                                completion(RequestResponse(success: false, request: nil,
                                                           error: response.error,
                                                           message: response.error?.localizedDescription))
                            }
        }
    }
    
    func getAll(completion: @escaping (RequestsResponse) -> Void) {
        guard let url = URL(string: Constants.userRequests) else {
            return
        }
        
        Alamofire.request(url, method: HTTPMethod.get, headers: getHeaders()).validate()
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completion(RequestsResponse(success: true, requests: response.result.value, error: nil, message: nil))
                case .failure(let error):
                    print(error)
                    completion(RequestsResponse(success: false, requests: nil, error: response.error, message: response.error?.localizedDescription))
                }
                
            }
    }
    
    func getAllByDate(from: Date, toDate: Date, completion: @escaping (RequestsResponse) -> Void) {
        
        let formatter = getDateFormatter()
        let params = ["startDate": formatter.string(from: from),
                      "endDate": formatter.string(from: toDate)]
        
        guard let url = URL(string: Constants.userRequests + "/3/dates") else {
            return
        }
        
        Alamofire.request(url, method: HTTPMethod.get, parameters: params, headers: getHeaders()).validate()
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completion(RequestsResponse(success: true, requests: response.result.value, error: nil, message: nil))
                case .failure(let error):
                    print(error)
                    completion(RequestsResponse(success: false, requests: nil, error: response.error, message: response.error?.localizedDescription))
                }
            }
    }
    
    func updateRequest(request: Request, completion: @escaping (RequestResponse) -> Void) {
        guard let url = URL(string: Constants.requests),
              let requestParameters = request.dictionary else {
                return
        }
        
        Alamofire.request(url, method: HTTPMethod.put, parameters: requestParameters, encoding: JSONEncoding.default,
                          headers: getHeaders()).responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<Request>) in
                            print(response)
                            switch response.result {
                            case .success:
                                print("Validation Successful")
                                completion(RequestResponse(success: true,
                                                           request: response.result.value ?? request,
                                                           error: nil, message: nil))
                            case .failure(let error):
                                print(error)
                                completion(RequestResponse(success: false, request: nil,
                                                           error: response.error,
                                                           message: response.error?.localizedDescription))
                            }
            }
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping (RequestsResponse) -> Void) {
        guard let url = URL(string: Constants.requestsToApprove) else {
            return
        }
        
        Alamofire.request(url, headers: getHeaders()).validate()
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completion(RequestsResponse(success: true, requests: response.result.value, error: nil, message: nil))
                case .failure(let error):
                    print(error)
                    completion(RequestsResponse(success: false, requests: nil, error: response.error, message: response.error?.localizedDescription))
                }
            }
    }
    
    func getAllByTeam(date: Date, teamId: Int, completion: @escaping (RequestsResponse) -> Void) {
        let urlString = Constants.requestsByTeamByMonth + "/\(teamId)/month"
        guard let url = URL(string: urlString) else {
            return
        }
        let formatter = getDateFormatter()
        let params = ["date": formatter.string(from: date)]
        Alamofire.request(url, method: HTTPMethod.get, parameters: params, headers: getHeaders()).validate()
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completion(RequestsResponse(success: true, requests: response.result.value, error: nil, message: nil))
                case .failure(let error):
                    print(error)
                    completion(RequestsResponse(success: false, requests: nil, error: response.error, message: response.error?.localizedDescription))
                }
            }
    }
    
    func getAllForEmployee(byEmail email: String, completion: @escaping (RequestsResponse) -> Void) {
        guard let url = URL(string: Constants.userRequests) else {
            return
        }
        
        Alamofire.request(url, method: HTTPMethod.get, headers: getHeaders()).validate()
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completion(RequestsResponse(success: true, requests: response.result.value, error: nil, message: nil))
                case .failure(let error):
                    print(error)
                    completion(RequestsResponse(success: false, requests: nil, error: response.error, message: response.error?.localizedDescription))
                }
                
            }
    }
    
    func getAllForAllEmployees(date: Date, completion: @escaping (RequestsResponse) -> Void) {
        guard let url = URL(string: Constants.requestsByMonth) else {
            return
        }
        let formatter = getDateFormatter()
        let params = ["date": formatter.string(from: date)]
        Alamofire.request(url, method: HTTPMethod.get, parameters: params, headers: getHeaders()).validate()
            .responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<[Request]>) in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completion(RequestsResponse(success: true, requests: response.result.value, error: nil, message: nil))
                case .failure(let error):
                    print(error)
                    completion(RequestsResponse(success: false, requests: nil, error: response.error, message: response.error?.localizedDescription))
                }
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
        formatter.dateFormat = Constants.dateFormat
        return formatter
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
