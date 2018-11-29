import Foundation
import Firebase

protocol UserUseCaseProtocol {
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func getAll(completion: @escaping ([String: [User]], [String: Int], GenericResponse<[User]>) -> Void)
    
    func getAllApprovers(completion: @escaping (GenericResponse<[User]>) -> Void)
    
    func add(user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func setFirebaseToken(completion: @escaping (GenericResponse<PushTokenDTO>?) -> Void)
    
    func update(user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func deleteFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func create(entity: User, completion: @escaping (Int) -> Void)
    
    func delete(user: User, completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func readUser(completion: @escaping (User?) -> Void)
    
    func create(entity: PushTokenDTO, userId: Int?, completion: @escaping (Int) -> Void)
    
    func read(userId: Int, completion: @escaping ([PushTokenDTO]?) -> Void)
    
    func read(pushToken: String, completion: @escaping (PushTokenDTO?) -> Void)
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
        userRepository?.getUsersByParameter(parameter: parameter, page: page, numberOfItems: numberOfItems) { response in
            completion(response)
        }
    }
    
    func add(user: User, completion: @escaping (GenericResponse<User>) -> Void) {
        userRepository?.add(user: user, completion: { response in
            completion(response)
        })
    }
    
    func getAll(completion: @escaping ([String: [User]], [String: Int], GenericResponse<[User]>) -> Void) {
        userRepository?.getAll(completion: { response in
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
        
        userRepository?.getAll(completion: { response in
            let userApprovers = response.item?.filter { $0.userRole == UserRole.hrManager.rawValue }
            completion(GenericResponse<[User]> (success: response.success, item: userApprovers, statusCode: response.statusCode,
                                                error: response.error,
                                                message: response.message))
        })
    }
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void) {
        userRepository?.getUser(email: getEmail()) { response in
            completion(response)
        }
    }
    
    func update(user: User, completion: @escaping (GenericResponse<User>) -> Void) {
        userRepository?.update(user: user, completion: { response in
            completion(response)
        })
    }
    
    func create(entity: User, completion: @escaping (Int) -> Void) {
        userDao?.deleteTokens(completion: { tokenSuccess in
            if !tokenSuccess {
                completion(-1)
                return
            }
            self.userDao?.emptyUsers { success in
                if !success {
                    completion(-1)
                    return
                }
                self.userDao?.create(entity: entity) { id in
                    guard let pushTokens = entity.userPushTokens else {
                        completion(-1)
                        return
                    }
                    for pushToken in pushTokens {
                        self.create(entity: pushToken, userId: id, completion: { _ in
                            
                        })
                    }
                    completion(id)
                }
            }
        })
    }
    
    func delete(user: User, completion: @escaping (GenericResponse<Any>?) -> Void) {
        userRepository?.delete(user: user, completion: { response in
            completion(response)
        })
    }
    
    func readUser(completion: @escaping (User?) -> Void) {
        userDao?.read { user in
            guard let userId = user?.id else {
                return
            }
            self.read(userId: userId, completion: { pushTokens in
                completion(User(user: user, userPushTokens: pushTokens))
            })
        }
    }
    
    func setFirebaseToken(completion: @escaping (GenericResponse<PushTokenDTO>?) -> Void) {
        
        if let firebaseToken = getFirebaseToken() {
            
            let pushTokenDTO = PushTokenDTO(pushToken: firebaseToken, name: UIDevice.current.name, platform: Platform.iOS)
            userRepository?.setFirebaseToken(pushTokenDTO: pushTokenDTO, completion: { response in
                completion(response)
            })
        } else {
            InstanceID.instanceID().instanceID { result, error in
                if let error = error {
                    completion(GenericResponse<PushTokenDTO> (success: false, item: nil,
                                                     statusCode: 400, error: error, message: "You didnt get push token, check support"))
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    self.userDetailsUseCase?.removeFirebaseToken()
                    self.userDetailsUseCase?.setFirebaseToken(result.token)
                    
                    let pushTokenDTO = PushTokenDTO(pushToken: result.token, name: UIDevice.current.name, platform: Platform.iOS)
                    self.userRepository?.setFirebaseToken(pushTokenDTO: pushTokenDTO, completion: { response in
                        completion(response)
                    })
                }
            }
        }
        
    }
    
    func read(userId: Int, completion: @escaping ([PushTokenDTO]?) -> Void) {
        userDao?.read(userId: userId, completion: { tokens in
            completion(tokens)
        })
    }
    
    func read(pushToken: String, completion: @escaping (PushTokenDTO?) -> Void) {
        userDao?.read(pushToken: pushToken, completion: { token in
            completion(token)
        })
    }
    
    func deleteFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void) {
        guard let pushToken = userDetailsUseCase?.getFirebaseToken() else {
            return
        }
        self.read(pushToken: pushToken, completion: { pushToken in
            guard let pushToken = pushToken else {
                return
            }
            self.userRepository?.deleteFirebaseToken(pushTokenDTO: pushToken, completion: { response in
                completion(response)
            })
        })
    }
    
    func create(entity: PushTokenDTO, userId: Int? = nil, completion: @escaping (Int) -> Void) {
        if let userId = userId {
            self.userDao?.create(entity: entity, userId: userId, completion: { response in
                completion(response)
            })
        } else {
            self.readUser(completion: { user in
                guard let userId = user?.id else {
                    return
                }
                self.userDao?.create(entity: entity, userId: userId, completion: { response in
                    completion(response)
                })
            })
        }
        
    }
    
    func getFirebaseToken() -> String? {
        return userDetailsUseCase?.getFirebaseToken()
    }
    
    func getEmail() -> String {
        return userDetailsUseCase?.getEmail() ?? ""
    }
}
