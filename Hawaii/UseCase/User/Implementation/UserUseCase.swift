import Foundation
import Firebase

protocol UserUseCaseProtocol {
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func getAll(completion: @escaping ([String: [User]], [String: Int], GenericResponse<[User]>) -> Void)
    
    func getAllApprovers(completion: @escaping (GenericResponse<[User]>) -> Void)
    
    func add(user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func setFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func update(user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func deleteFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func create(entity: User, completion: @escaping (Int) -> Void)
    
    func delete(user: User, completion: @escaping (GenericResponse<Any>?) -> Void)
    
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
    
    func add(user: User, completion: @escaping (GenericResponse<User>) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<User> (success: false, item: nil, statusCode: 401,
                                                error: nil,
                                                message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.add(token: token, user: user, completion: { response in
            completion(response)
        })
    }
    
    func getAll(completion: @escaping ([String: [User]], [String: Int], GenericResponse<[User]>) -> Void) {
        guard let token = getToken() else {
            completion([:], [:], GenericResponse<[User]> (success: false, item: nil, statusCode: 401,
                                              error: nil,
                                              message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.getAll(token: token, completion: { response in
            let users = response.item ?? []
            var teamIdDictionary: [String: Int] = [:]
            for user in users {
                guard let userTeamId = user.teamId,
                      let userTeamName = user.teamName else {
                    continue
                }
                teamIdDictionary[userTeamName] = userTeamId
            }
            completion(Dictionary(grouping: response.item ?? [], by: { $0.teamName ?? "" }), teamIdDictionary, response)
        })
    }
    
    func getAllApprovers(completion: @escaping (GenericResponse<[User]>) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<[User]> (success: false, item: nil, statusCode: 401,
                                                          error: nil,
                                                          message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.getAll(token: token, completion: { response in
            let userApprovers = response.item?.filter { $0.userRole == UserRole.hrManager.rawValue}
            completion(GenericResponse<[User]> (success: response.success, item: userApprovers, statusCode: response.statusCode,
                                                error: response.error,
                                                message: response.message))
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
    
    func update(user: User, completion: @escaping (GenericResponse<User>) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<User> (success: false, item: nil, statusCode: 401,
                                              error: nil,
                                              message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.update(token: token, user: user, completion: { response in
            completion(response)
        })
    }
    
    func create(entity: User, completion: @escaping (Int) -> Void) {
        userDao?.create(entity: entity) { id in
            completion(id)
        }
    }
    
    func delete(user: User, completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                              error: nil,
                                              message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.delete(token: token, user: user, completion: { response in
            completion(response)
        })
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
            let pushTokenDTO = PushTokenDTO(pushToken: firebaseToken, name: UIDevice.current.name, platform: Platform.iOS)
            userRepository?.setFirebaseToken(token: token, pushTokenDTO: pushTokenDTO, completion: { response in
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
                    let pushTokenDTO = PushTokenDTO(pushToken: result.token, name: UIDevice.current.name, platform: Platform.iOS)
                    self.userRepository?.setFirebaseToken(token: token, pushTokenDTO: pushTokenDTO, completion: { response in
                        completion(response)
                    })
                }
            }
        }
        
    }
    
    func deleteFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let token = getToken() else {
            completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                                            error: nil,
                                                            message: LocalizedKeys.General.emptyToken.localized()))
            return
        }
        userRepository?.deleteFirebaseToken(token: token, pushTokenDTO: PushTokenDTO(), completion: { response in
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
