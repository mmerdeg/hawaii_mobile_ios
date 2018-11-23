import Foundation

protocol UserRepositoryProtocol: GenericRepositoryProtocol {
    
    func signIn(accessToken: String, completion: @escaping (GenericResponse<(String, User)>) -> Void)
    
    func getUser(email: String, completion: @escaping (GenericResponse<User>?) -> Void)
    
    func getUsersByParameter(parameter: String, page: Int, numberOfItems: Int, completion: @escaping (UsersResponse) -> Void)
    
    func getAll(completion: @escaping (GenericResponse<[User]>) -> Void)
    
    func setFirebaseToken(firebaseToken: String, completion: @escaping (GenericResponse<Any>?) -> Void)
}
