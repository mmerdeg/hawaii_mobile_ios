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

protocol SignInApiProtocol {
    func signIn(accessToken: String, completion: @escaping (String) -> Void)
}

class SignInApi: SignInApiProtocol {
    
    let signInApi: SignInApiProtocol?
    
    init(signInApi: SignInApiProtocol) {
        self.signInApi = signInApi
    }
    
    init() {
        signInApi = nil
    }
    
    func signIn(accessToken: String, completion: @escaping (String) -> Void) {
//        guard let url = URL(string: "https://hawaii2.execom.eu/hawaii/signin") else {
//            return
//        }
        
        let headers = HTTPHeaders.init(dictionaryLiteral: ("Authorization", accessToken))
        Alamofire.request(Constants.signin, headers: headers).response { response in
            print(response)
            guard let resp = response.response?.allHeaderFields else {
                return
            }
            guard let token = response.response?.allHeaderFields["X-AUTH-TOKEN"] as? String else {
                completion("")
                return
            }
            
            completion(token)
        }
    }
    
}
