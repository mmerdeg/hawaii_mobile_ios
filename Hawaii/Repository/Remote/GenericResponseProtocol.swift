//
//  GenericResponseProtocol.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/21/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import Alamofire

protocol GenericResponseProtocol {
    func genericRequest<T: Decodable>(_ url: URL, method: HTTPMethod,
                                      parameters: Parameters?, encoding: ParameterEncoding,
                                      headers: HTTPHeaders?, completion: @escaping (GenericResponseSingle<T>) -> Void)
}

extension GenericResponseProtocol {
    
    func genericRequest<T: Decodable>(_ url: URL, method: HTTPMethod = .get,
                                      parameters: Parameters? = nil,
                                      encoding: ParameterEncoding = URLEncoding.default,
                                      headers: HTTPHeaders? = nil,
                                      completion: @escaping (GenericResponseSingle<T>) -> Void) {
        Alamofire.request(url, method: method, parameters: parameters, encoding: encoding,
                          headers: headers).validate().responseDecodableObject(keyPath: nil, decoder: getDecoder()) { (response: DataResponse<T>) in
                            switch response.result {
                            case .success:
                                print("Validation Successful")
                                completion(GenericResponseSingle<T> (success: true, item: response.result.value, error: nil, message: nil))
                            case .failure(let error):
                                print(error)
                                
                                completion(GenericResponseSingle<T> (success: false, item: nil,
                                                                     error: response.error,
                                                               message: response.error?.localizedDescription))
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
}
