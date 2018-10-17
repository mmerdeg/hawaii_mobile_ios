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

//    var userDetailsUseCase: UserDetailsUseCaseProtocol =
//        UserDetailsUseCase(userDetailsRepository: UserDetailsRepository(keyChainRepository: KeyChainRepository()))
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    let authHeader = "X-AUTH-TOKEN"
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void) {
        guard let url = URL(string: Constants.search) else {
            return
        }
        let params = ["page": page,
                      "size": numberOfItems,
                      "active": true,
                      "searchQuery": parameter] as [String: Any]
        Alamofire.request(url, method: HTTPMethod.get, parameters: params, headers: getHeaders()).validate()
            .responseDecodableObject { (response: DataResponse<Page>) in
                guard let searchedContent = response.result.value else {
                    completion(UsersResponse(success: false, users: nil, maxUsers: nil,
                                             error: response.error,
                                             message: response.error?.localizedDescription))
                    return
                }
                switch response.result {
                case .success:
                    print("Validation Successful")
                    completion(UsersResponse(success: true, users: searchedContent.content,
                                             maxUsers: searchedContent.totalElements, error: nil, message: nil))
                case .failure(let error):
                    print(error)
                    completion(UsersResponse(success: false, users: nil, maxUsers: nil,
                                             error: response.error,
                                             message: response.error?.localizedDescription))
                }
            }
    }
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void) {
        guard let email = userDetailsUseCase?.getEmail() else {
            return
        }
        guard let url = URL(string: Constants.getUser + "/\(email)") else {
            return
        }
        genericCodableRequest(value: User.self, url, headers: getHeaders()) { response in
            completion(response)
        }
    }
    
    func signIn(accessToken: String, completion: @escaping (GenericResponse<(String, User)>) -> Void) {
        guard let url = URL(string: Constants.signin) else {
            return
        }
        let headers = HTTPHeaders.init(dictionaryLiteral: ("Authorization", accessToken))
        Alamofire.request(url, headers: headers).validate().responseDecodableObject { (response: DataResponse<User>) in
            guard let user = response.value,
                let token = response.response?.allHeaderFields["X-AUTH-TOKEN"] as? String else {
                    completion(GenericResponse<(String, User)>(success: false, item: nil, statusCode: response.response?.statusCode,
                                                               error: response.error,
                                                               message: response.error?.localizedDescription))
                    return
            }
            completion(GenericResponse<(String, User)>(success: true, item: (token, user),
                                                       statusCode: response.response?.statusCode,
                                                       error: nil, message: nil))
        }
        
    }
    
    func getHeaders() -> HTTPHeaders {
        let token = userDetailsUseCase?.getToken()
        return [authHeader: token ?? ""]
    }
    
    func getEmail() -> String {
        return userDetailsUseCase?.getEmail() ?? ""
    }
    
}
