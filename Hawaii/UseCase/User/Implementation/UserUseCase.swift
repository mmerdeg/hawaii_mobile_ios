import Foundation

protocol UserUseCaseProtocol {
    
    func signIn(accessToken: String, completion: @escaping (GenericResponse<(String, User)>) -> Void)
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func setFirebaseToken(completion: @escaping (GenericResponse<Any>?) -> Void)
    
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
        userRepository?.getUsersByParameter(token: getToken(), parameter: parameter, page: page, numberOfItems: numberOfItems) { response in
            completion(response)
        }
    }
    
    func getUser(completion: @escaping (GenericResponse<User>?) -> Void) {
        userRepository?.getUser(token: getToken(), email: getEmail()) { response in
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
        userRepository?.setFirebaseToken(token: getToken(), firebaseToken: getFirebaseToken(), completion: { response in
            completion(response)
        })
    }
    
    func getFirebaseToken() -> String {
        return userDetailsUseCase?.getFirebaseToken() ?? ""
    }

    func getToken() -> String {
        return userDetailsUseCase?.getToken() ?? ""
    }
    
    func getEmail() -> String {
        return userDetailsUseCase?.getEmail() ?? ""
    }
}
