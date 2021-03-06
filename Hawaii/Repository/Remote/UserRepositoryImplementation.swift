import Foundation
import Alamofire
import CodableAlamofire

class UserRepositoryImplementation: SessionManager, UserRepository {
    
    let signInUrl = ApiConstants.baseUrl + "/signin"
    
    let getUserUrl = ApiConstants.baseUrl + "/users"
    
    let searchUsersUrl = ApiConstants.baseUrl + "/users/search"
    
    let firebaseTokenUrl = ApiConstants.baseUrl + "/token"
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void) {
        guard let url = URL(string: searchUsersUrl) else {
            return
        }
        let pageKey = "page",
            sizeKey = "size",
            userStatusType = "userStatusType",
            searchQueryKey = "searchQuery"
        
        let params = [pageKey: page, sizeKey: numberOfItems, userStatusType: StatusType.active.rawValue, searchQueryKey: parameter] as [String: Any]
        
        DispatchQueue.global(qos: .background).async {
            self.session.request(url, method: HTTPMethod.get, parameters: params).validate()
                .responseDecodableObject { (response: DataResponse<Page>) in
                    guard let searchedContent = response.result.value else {
                        completion(UsersResponse(success: false, users: nil, statusCode: response.response?.statusCode, maxUsers: nil,
                                                 error: response.error,
                                                 message: response.error?.localizedDescription))
                        return
                    }
                    switch response.result {
                    case .success:
                        print("Validation Successful")
                        completion(UsersResponse(success: true, users: searchedContent.content, statusCode: response.response?.statusCode,
                                                 maxUsers: searchedContent.totalElements, error: nil, message: nil))
                    case .failure(let error):
                        print(error)
                        completion(UsersResponse(success: false, users: nil, statusCode: response.response?.statusCode, maxUsers: nil,
                                                 error: response.error,
                                                 message: response.error?.localizedDescription))
                    }
                }
        }
    }
    
    func getAll(completion: @escaping (GenericResponse<[User]>) -> Void) {
        guard let url = URL(string: getUserUrl) else {
            return
        }
        let userStatusType = "userStatusType"
        
        let params = [userStatusType: StatusType.active.rawValue] as [String: Any]
        genericCodableRequest(value: [User].self, url, parameters: params) { response in
            completion(response)
        }
    }
    
    func getAllApprovers(completion: @escaping (GenericResponse<[User]>) -> Void) {
        guard let url = URL(string: getUserUrl) else {
            return
        }
        let activeKey = "active"
        
        let params = [activeKey: true] as [String: Any]
        genericCodableRequest(value: [User].self, url, parameters: params) { response in
            completion(response)
        }
    }
    
    func add(user: User, completion: @escaping (GenericResponse<User>) -> Void) {
        guard let url = URL(string: getUserUrl),
            let userParameters = user.dictionary else {
                return
        }
        genericCodableRequest(value: User.self, url, method: .post,
                              parameters: userParameters, encoding: JSONEncoding.default) { response in
                                if response.statusCode == 416 {
                                    completion(GenericResponse<User> (success: false, item: nil, statusCode: response.statusCode,
                                                                         error: response.error,
                                                                         message: LocalizedKeys.Api.tooManyDays.localized()))
                                } else if response.statusCode == 409 {
                                    completion(GenericResponse<User> (success: false, item: nil, statusCode: response.statusCode,
                                                                         error: response.error,
                                                                         message: LocalizedKeys.Api.alreadyExists.localized()))
                                } else {
                                    completion(response)
                                }
        }
    }
    
    func delete(user: User, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let id = user.id,
              let url = URL(string: getUserUrl + "/\(id)") else {
                return
        }
        
        genericJSONRequest(url, method: HTTPMethod.delete) { response in
            completion(response)
        }
    }
    
    func deleteFirebaseToken(pushTokenDTO: PushTokenDTO, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let id = pushTokenDTO.pushTokenId,
              let url = URL(string: firebaseTokenUrl + "/\(id)") else {
            return
        }
        genericJSONRequest(url, method: HTTPMethod.delete) { response in
            completion(response)
        }
    }
    
    func setFirebaseToken(pushTokenDTO: PushTokenDTO, completion: @escaping (GenericResponse<PushTokenDTO>?) -> Void) {
        guard let url = URL(string: firebaseTokenUrl) else {
            return
        }
        let params = pushTokenDTO.dictionary
        
        genericCodableRequest(value: PushTokenDTO.self, url, method: HTTPMethod.post,
                              parameters: params, encoding: JSONEncoding.default) { response in
            completion(response)
        }
    }
    
    func getUser(email: String, completion: @escaping (GenericResponse<User>?) -> Void) {
        guard let url = URL(string: getUserUrl + "/\(email)") else {
            return
        }
        genericCodableRequest(value: User.self, url) { response in
            completion(response)
        }
    }
    
    func update(user: User, completion: @escaping (GenericResponse<User>) -> Void) {
        guard let url = URL(string: getUserUrl),
            let userParameters = user.dictionary else {
                return
        }
        genericCodableRequest(value: User.self, url, method: .put,
                              parameters: userParameters,
                              encoding: JSONEncoding.default) { response in
                                completion(response)
        }
    }
}
