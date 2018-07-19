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
    func signIn(accessToken: String, completion: @escaping (Bool) -> Void)
}

class SignInApi: SignInApiProtocol {
    
    let signInApi: SignInApiProtocol?
    
    init(signInApi: SignInApiProtocol) {
        self.signInApi = signInApi
    }
    
    init() {
        signInApi = nil
    }
    
    func signIn(accessToken: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://hawaii2.execom.eu/hawaii/signin") else {
            return
        }
        let decoder = JSONDecoder()
        Alamofire.request(url, headers: HTTPHeaders.init(dictionaryLiteral: ("Authorization", "Bearer "+accessToken))).response { response in
            print(response.response?.statusCode)
            completion(response.response?.statusCode == 200)
        }
    }
    
}
