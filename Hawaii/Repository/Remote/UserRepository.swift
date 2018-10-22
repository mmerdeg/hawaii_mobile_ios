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
    
    let authHeader = "X-AUTH-TOKEN"
    
    let signInUrl = ApiConstants.baseUrl + "/signin"
    
    let getUserUrl = ApiConstants.baseUrl + "/users"
    
    let searchUsersUrl = ApiConstants.baseUrl + "/users/search"
    
    let firebaseTokenUrl = ApiConstants.baseUrl + "/token"
    
    func getUsersByParameter(token: String, parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void) {
        guard let url = URL(string: searchUsersUrl) else {
            return
        }
        let pageKey = "page",
            sizeKey = "size",
            activeKey = "active",
            searchQueryKey = "searchQuery"
        
        let params = [pageKey: page, sizeKey: numberOfItems, activeKey: true, searchQueryKey: parameter] as [String: Any]
        
        Alamofire.request(url, method: HTTPMethod.get, parameters: params, headers: getHeaders(token: token)).validate()
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
    
    func setFirebaseToken(token: String, firebaseToken: String, completion: @escaping (GenericResponse<Any>?) -> Void) {
            guard let url = URL(string: firebaseTokenUrl) else {
                return
            }
            let pushTokenKey = "pushToken"

            let params = [pushTokenKey: firebaseToken] as [String: Any]
            genericJSONRequest(url, method: HTTPMethod.put, parameters: params, headers: getHeaders(token: token)) { response in
                completion(response)
            }
    }
    
    func getUser(token: String, email: String, completion: @escaping (GenericResponse<User>?) -> Void) {
        guard let url = URL(string: getUserUrl + "/\(email)") else {
            return
        }
        genericCodableRequest(value: User.self, url, headers: getHeaders(token: token)) { response in
            completion(response)
        }
    }
    
    func signIn(accessToken: String, completion: @escaping (GenericResponse<(String, User)>) -> Void) {
        guard let url = URL(string: signInUrl) else {
            return
        }
        let accessTokenKey = "Authorization"
        let headers = HTTPHeaders.init(dictionaryLiteral: (accessTokenKey, accessToken))
        
        Alamofire.request(url, headers: headers).validate().responseDecodableObject { (response: DataResponse<User>) in
            guard let user = response.value,
                let token = response.response?.allHeaderFields[self.authHeader] as? String else {
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
    
    func getHeaders(token: String) -> HTTPHeaders {
        return [authHeader: token]
    }
    
}
