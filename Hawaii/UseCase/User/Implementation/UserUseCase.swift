import Foundation
import Firebase

protocol UserUseCaseProtocol {
    
    func signIn(accessToken: String, completion: @escaping (GenericResponse<(String, User)>) -> Void)
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func getAll(completion: @escaping ([String: [User]], GenericResponse<[User]>) -> Void)
    
    func setFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func setEmptyFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func createUser(entity: User, completion: @escaping (Int) -> Void)
    
    func readUser(completion: @escaping (User?) -> Void)
}

class UserUseCase: UserUseCaseProtocol {
    
    let userRepository: UserRepositoryProtocol?
    
    let userDao: UserDaoProtocol?
    
    let userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    init(userRepository: UserRepositoryProtocol, userDao: UserDaoProtocol,
         userDetailsUseCase: UserDetailsUseCaseProtocol) {
        self.userRepository = userRepository
        self.userDao = userDao
        self.userDetailsUseCase = userDetailsUseCase
    }
    
    func signIn(accessToken: String, completion: @escaping (GenericResponse<(String, User)>) -> Void) {
        userRepository?.signIn(accessToken: accessToken) { response in
            completion(response)
        }
    }
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void) {
        guard let token = getToken() else {
            completion(UsersResponse(success: false, users: nil, statusCode: 401, maxUsers: nil,
                                     error: nil,
                                     message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.getUsersByParameter(token: token, parameter: parameter, page: page, numberOfItems: numberOfItems) { response in
            completion(response)
        }
    }
    
    func getAll(completion: @escaping ([String: [User]], GenericResponse<[User]>) -> Void) {
        guard let token = getToken() else {
            completion([:], GenericResponse<[User]> (success: false, item: nil, statusCode: 401,
                                              error: nil,
                                              message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.getAll(token: token, completion: { response in
            completion(Dictionary(grouping: response.item ?? [], by: { $0.teamName ?? "" }), response)
        })
    }
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<User> (success: false, item: nil, statusCode: 401,
                                             error: nil,
                                             message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.getUser(token: token, email: getEmail()) { response in
            completion(response)
        }
    }
    
    func createUser(entity: User, completion: @escaping (Int) -> Void) {
        userDao?.create(entity: entity) { id in
            completion(id)
        }
    }
    
    func readUser(completion: @escaping (User?) -> Void) {
        userDao?.read { user in
            completion(user)
        }
    }
    
    func setFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void) {
        if let firebaseToken = getFirebaseToken() {
            guard let token = getToken() else {
                completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                                  error: nil,
                                                  message: LocalizedKeys.General.emptyToken.localized()))
                return
            }
            userRepository?.setFirebaseToken(token: token, firebaseToken: firebaseToken, completion: { response in
                completion(response)
            })
        } else {
            InstanceID.instanceID().instanceID { result, error in
                if let error = error {
                    completion(GenericResponse<Any> (success: false, item: nil,
                                                     statusCode: 400, error: error, message: "You didnt get push token, check support"))
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    self.userDetailsUseCase?.removeFirebaseToken()
                    self.userDetailsUseCase?.setFirebaseToken(result.token)
                    guard let token = self.getToken() else {
                        completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                                          error: nil,
                                                          message: LocalizedKeys.General.emptyToken.localized()))
                        return
                    }
                    self.userRepository?.setFirebaseToken(token: token, firebaseToken: result.token, completion: { response in
                        completion(response)
                    })
                }
            }
        }
        
    }
    
    func setEmptyFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                                            error: nil,
                                                            message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.setFirebaseToken(token: token, firebaseToken: "", completion: { response in
            completion(response)
        })
    }
    
    func getFirebaseToken() -> String? {
        return userDetailsUseCase?.getFirebaseToken()
    }

    func getToken() -> String? {
        return userDetailsUseCase?.getToken()
    }
    
    func getEmail() -> String {
        return userDetailsUseCase?.getEmail() ?? ""
    }
}
