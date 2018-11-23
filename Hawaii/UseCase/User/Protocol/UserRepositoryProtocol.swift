import Foundation

protocol UserRepositoryProtocol: GenericRepositoryProtocol {
    
    func getUser(email: String, completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func add(user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func getAll(completion: @escaping (GenericResponse<[User]>) -> Void)
    
    func update(user: User, completion: @escaping (GenericResponse<User>) -> Void)
    
    func setFirebaseToken(pushTokenDTO: PushTokenDTO, completion: @escaping (GenericResponse<Any>?) -> Void)
    
    func deleteFirebaseToken(pushTokenDTO: PushTokenDTO, completion: @escaping (GenericResponse<Any>?) -> Void)
}
