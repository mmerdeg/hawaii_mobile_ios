//
//  SignInApi.swift
//  Hawaii
//
//  Created by Server on 7/19/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import CodableAlamofire
import Alamofire

class SignInApi: SignInApiProtocol, GenericRepositoryProtocol {
    
    func signIn(accessToken: String, completion: @escaping (GenericResponse<String>) -> Void) {
        guard let url = URL(string: Constants.signin) else {
            return
        }
        let headers = HTTPHeaders.init(dictionaryLiteral: ("Authorization", accessToken))
        Alamofire.request(url, headers: headers).validate().responseDecodableObject { (response: DataResponse<User>) in
            guard let token = response.response?.allHeaderFields["X-AUTH-TOKEN"] as? String else {
                completion(GenericResponse<String>(success: false, item: "", statusCode: response.response?.statusCode,
                                                   error: response.error,
                                                   message: response.error?.localizedDescription))
                return
            }
            completion(GenericResponse<String>(success: true, item: token, statusCode: response.response?.statusCode, error: nil, message: nil))
        }
        
    }
    
}
