import Foundation

protocol UserRepositoryProtocol: GenericRepositoryProtocol {
    
    func signIn(accessToken: String, completion: @escaping (GenericResponse<(String, User)>) -> Void)
    
    func getUser(token: String, email: String, completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(token: String, parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func getAll(token: String, completion: @escaping (GenericResponse<[User]>) -> Void)
    
    func setFirebaseToken(token: String, firebaseToken: String, completion: @escaping (GenericResponse<Any>?) -> Void)
}
