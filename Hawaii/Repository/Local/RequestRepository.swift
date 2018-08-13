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
    
    func add(request: Request, completion: @escaping (Request) -> Void) {
        requests?.append(request)
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        encoder.dateEncodingStrategy = .formatted(formatter)
        guard let encodedData = try? encoder.encode(request),
            let url = URL(string: Constants.requests),
            let parameters = try? JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any],
            let tempParameters = parameters else {
                return
        }
        print(tempParameters)
        Alamofire.request(url, method: HTTPMethod.post, parameters: tempParameters, encoding: JSONEncoding.default).responseString { response in
            print(response.error ?? "")
            completion(request)
        }
    }
    
    func getAll(completion: @escaping ([Request]) -> Void) {
        
        guard let url = URL(string: Constants.userRequests + "/1") else {
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let decoder = JSONDecoder()
        //7ddcfe67-4b19-461e-a917-4e15ff1131c1
        decoder.dateDecodingStrategy = .formatted(formatter)
        Alamofire.request(url).responseDecodableObject(keyPath: nil, decoder: decoder) { (response: DataResponse<[Request]>) in
            print(response)
            completion(response.result.value ?? [])
        }
    }
    func getAllByDate(from: Date, toDate: Date, completion: @escaping ([Request]) -> Void) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        print(formatter.string(from: from))
        let params = ["startDate": formatter.string(from: from),
                      "endDate": formatter.string(from: toDate)]
        guard let url = URL(string: Constants.userRequests + "/1/dates") else {
            return
        }
        let decoder = JSONDecoder()
        //7ddcfe67-4b19-461e-a917-4e15ff1131c1
        decoder.dateDecodingStrategy = .formatted(formatter)
        Alamofire.request(url, method: HTTPMethod.get,
                          parameters: params).responseDecodableObject(keyPath: nil, decoder: decoder) { (response: DataResponse<[Request]>) in
            print(response)
            completion(response.result.value ?? [])
        }
    }
    
    func updateRequest(request: Request, completion: @escaping (Request) -> Void) {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        encoder.dateEncodingStrategy = .formatted(formatter)
        guard let encodedData = try? encoder.encode(request),
            let url = URL(string: Constants.requests),
            let parameters = try? JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any],
            let tempParameters = parameters else {
                return
        }
        print(tempParameters)
        Alamofire.request(url, method: HTTPMethod.put, parameters: tempParameters, encoding: JSONEncoding.default).responseString { response in
            print(response.error ?? "")
            //completion(request)
        }
    }
    
    func getAllPendingForApprover(approver: Int, completion: @escaping ([Request]) -> Void) {
        guard let url = URL(string: Constants.userRequests + "/1") else {
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let decoder = JSONDecoder()
        //7ddcfe67-4b19-461e-a917-4e15ff1131c1
        decoder.dateDecodingStrategy = .formatted(formatter)
        Alamofire.request(url).responseDecodableObject(keyPath: nil, decoder: decoder) { (response: DataResponse<[Request]>) in
            print(response)
            completion(response.result.value ?? [])
        }
    }
}
