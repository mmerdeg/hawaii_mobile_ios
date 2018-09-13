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
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void) {
        guard let url = URL(string: Constants.getUser + "/\(userDetailsUseCase.getEmail())") else {
            return
        }
        
        Alamofire.request(url, headers: getHeaders()).validate().responseDecodableObject { (response: DataResponse<User>) in
            guard let user = response.result.value else {
                completion(UsersResponse(success: false, users: nil, maxUsers: 10,
                                         error: response.error,
                                         message: response.error?.localizedDescription))
                return
            }
            switch response.result {
            case .success:
                print("Validation Successful")
                completion(UsersResponse(success: true, users: [user, user], maxUsers: 10, error: nil, message: nil))
            case .failure(let error):
                print(error)
                completion(UsersResponse(success: false, users: nil, maxUsers: 10,
                                         error: response.error,
                                         message: response.error?.localizedDescription))
            }
        }
    }
    
    func getUser(completion: @escaping (UserResponse?) -> Void) {
        guard let url = URL(string: Constants.getUser + "/\(userDetailsUseCase.getEmail())") else {
            return
        }
        
        Alamofire.request(url, headers: getHeaders()).responseDecodableObject { (response: DataResponse<User>) in
            print(response)
            switch response.result {
            case .success:
                print("Validation Successful")
                completion(UserResponse(success: true, user: response.result.value, error: nil, message: nil))
            case .failure(let error):
                print(error)
                completion(UserResponse(success: false, user: nil,
                                         error: response.error,
                                         message: response.error?.localizedDescription))
            }
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
