//
//  UserUseCaseImplementation.swift
//  Hawaii
//
//  Created by Ivan Divljak on 12/3/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import Firebase

protocol UserUseCase {
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func getAll(completion: @escaping ([String: [User]], [String: Int], GenericResponse<[User]>) -> Void)
    
    func getAllApprovers(completion: @escaping (GenericResponse<[User]>) -> Void)
    
    func add(user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func delete(user: User, completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func setFirebaseToken(completion: @escaping (GenericResponse<PushTokenDTO>?) -> Void)
    
    func update(user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func deleteFirebaseToken(pushToken: String?, completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func create(entity: User, completion: @escaping (Int) -> Void)
    
    func readUser(completion: @escaping (User?) -> Void)
}

class UserUseCaseImplementation: UserUseCase {
    
    let userRepository: UserRepository?
    
    let userDao: UserDao?
    
    let userDetailsUseCase: UserDetailsUseCase?
    
    init(userRepository: UserRepository, userDao: UserDao,
         userDetailsUseCase: UserDetailsUseCase) {
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
            if !(response?.success ?? false) {
                completion(response)
                return
            } else {
                guard let user = response?.item else {
                    completion(response)
                    return
                }
                self.create(entity: user, completion: { _ in
                    completion(response)
                    return
                })
            }
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
                    self.userDao?.create(entity: pushTokens, userId: id, completion: { _ in
                        completion(id)
                    })
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
                completion(nil)
                return
            }
            self.userDao?.read(userId: userId, completion: { pushTokens in
                completion(User(user: user, userPushTokens: pushTokens))
            })
        }
    }
    
    func setFirebaseToken(completion: @escaping (GenericResponse<PushTokenDTO>?) -> Void) {
        
        if let firebaseToken = getFirebaseToken() {
            
            let pushTokenDTO = PushTokenDTO(pushToken: firebaseToken, name: UIDevice.current.name, platform: Platform.iOS)
            setTokenService(pushTokenDTO: pushTokenDTO) { response in
                completion(response)
            }
        } else {
            InstanceID.instanceID().instanceID { result, error in
                if let error = error {
                    completion(GenericResponse<PushTokenDTO> (success: false, item: nil,
                                                              statusCode: 400, error: error, message: "You didnt get push token, check support"))
                } else if let result = result {
                    self.userDetailsUseCase?.removeFirebaseToken()
                    self.userDetailsUseCase?.setFirebaseToken(result.token)
                    let pushTokenDTO = PushTokenDTO(pushToken: result.token, name: UIDevice.current.name, platform: Platform.iOS)
                    self.setTokenService(pushTokenDTO: pushTokenDTO) { response in
                        completion(response)
                    }
                    
                }
            }
        }
        
    }
    
    func setTokenService(pushTokenDTO: PushTokenDTO, completion: @escaping (GenericResponse<PushTokenDTO>?) -> Void) {
        self.userRepository?.setFirebaseToken(pushTokenDTO: pushTokenDTO, completion: { response in
            if !(response?.success ?? false) {
                completion(response)
            } else {
                self.readUser(completion: { user in
                    guard let userId = user?.id else {
                        completion(response)
                        return
                    }
                    self.userDao?.create(entity: pushTokenDTO, userId: userId, completion: { _ in
                        completion(response)
                    })
                })
                
            }
        })
    }
    
    func deleteFirebaseToken(pushToken: String? = nil, completion: @escaping (GenericResponse<Any>?) -> Void) {
        if let pushToken = pushToken {
            guard let devicePushToken = userDetailsUseCase?.getFirebaseToken() else {
                completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                                 error: nil,
                                                 message: LocalizedKeys.General.emptyToken.localized()))
                return
            }
            if devicePushToken == pushToken {
                completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                                 error: nil,
                                                 message: LocalizedKeys.General.equalToken.localized()))
                return
            }
            deleteFirebaseService(pushToken: pushToken) { response in
                completion(response)
            }
        } else {
            guard let pushToken = userDetailsUseCase?.getFirebaseToken() else {
                completion(GenericResponse<Any> (success: false, item: nil, statusCode: 401,
                                                 error: nil,
                                                 message: LocalizedKeys.General.emptyToken.localized()))
                return
            }
            deleteFirebaseService(pushToken: pushToken) { response in
                completion(response)
            }
        }
    }
    
    func deleteFirebaseService(pushToken: String, completion: @escaping (GenericResponse<Any>?) -> Void) {
        self.userDao?.read(pushToken: pushToken, completion: { pushTokenDTO in
            guard let pushTokenDTO = pushTokenDTO else {
                return
            }
            self.userRepository?.deleteFirebaseToken(pushTokenDTO: pushTokenDTO, completion: { response in
                if !(response?.success ?? false) {
                    completion(response)
                }
                self.userDao?.deleteToken(pushToken: pushToken, completion: { _ in
                    completion(response)
                })
            })
        })
    }
    
    func getFirebaseToken() -> String? {
        return userDetailsUseCase?.getFirebaseToken()
    }
    
    func getEmail() -> String {
        return userDetailsUseCase?.getEmail() ?? ""
    }
}
