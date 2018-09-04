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
    
    func signIn(accessToken: String, completion: @escaping (String) -> Void) {
//        guard let url = URL(string: "https://hawaii2.execom.eu/hawaii/signin") else {
//            return
//        }
        
    }
    
    func signIn(accessToken: String, completion: @escaping (TokenResponse) -> Void) {
        let headers = HTTPHeaders.init(dictionaryLiteral: ("Authorization", accessToken))
        Alamofire.request(Constants.signin, headers: headers).validate().response { response in
            guard let token = response.response?.allHeaderFields["X-AUTH-TOKEN"] as? String else {
                completion(TokenResponse(success: false, token: "", error: response.error, message: response.error?.localizedDescription))
                return
            }
            completion(TokenResponse(success: true, token: token, error: nil, message: nil))
        }
    }
    
}
