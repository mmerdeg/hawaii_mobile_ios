import Foundation

protocol UserRepositoryProtocol: GenericRepositoryProtocol {
    
    func getUser(token: String, email: String, completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(token: String, parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func add(token: String, user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func getAll(token: String, completion: @escaping (GenericResponse<[User]>) -> Void)
    
    func getAllApprovers(token: String, completion: @escaping (GenericResponse<[User]>) -> Void)
    
    func update(token: String, user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func delete(token: String, user: User, completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func setFirebaseToken(token: String, pushTokenDTO: PushTokenDTO, completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func deleteFirebaseToken(token: String, pushTokenDTO: PushTokenDTO, completion: @escaping (GenericResponse<Any>?) -> Void)

}
