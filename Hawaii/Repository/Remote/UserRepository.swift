//
//  UserRepository.swift
//  Hawaii
//
//  Created by Ivan Divljak on 8/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire

class UserRepository: UserRepositoryProtocol {
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol = UserDetailsUseCase(userDetailsRepository: UserDetailsRepository())
    
    let authHeader = "X-AUTH-TOKEN"
    
    func getUser(completion: @escaping (User?) -> Void) {
        
        guard let url = URL(string: Constants.getUser + "/\(userDetailsUseCase.getEmail())") else {
                return
        }
        
        Alamofire.request(url, headers: getHeaders()).responseDecodableObject { (response: DataResponse<User>) in
            print(response)
            completion(response.result.value)
        }
    
    }
    
    func getHeaders() -> HTTPHeaders {
        let token = userDetailsUseCase.getToken()
        return [authHeader: token]
    }
    
    func getEmail() -> String {
        return userDetailsUseCase.getEmail()
    }
    
}
