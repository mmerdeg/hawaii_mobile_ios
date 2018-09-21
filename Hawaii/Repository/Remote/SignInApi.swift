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

class SignInApi: SignInApiProtocol {
    
    func signIn(accessToken: String, completion: @escaping (GenericResponseSingle<String>) -> Void) {
        guard let url = URL(string: Constants.signin) else {
            return
        }
        let headers = HTTPHeaders.init(dictionaryLiteral: ("Authorization", accessToken))
        Alamofire.request(url, headers: headers).validate().response { response in
            guard let token = response.response?.allHeaderFields["X-AUTH-TOKEN"] as? String else {
                completion(GenericResponseSingle<String>(success: false, item: "",
                                                         error: response.error,
                                                         message: response.error?.localizedDescription))
                return
            }
            completion(GenericResponseSingle<String>(success: true, item: token, error: nil, message: nil))
        }
    }
    
}
