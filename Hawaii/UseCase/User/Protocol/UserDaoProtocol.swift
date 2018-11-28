import Foundation

protocol UserDaoProtocol {
    
    func create(entity: User, completion: @escaping (Int) -> Void)
    
    func read(completion: @escaping (User?) -> Void)
    
    func emptyUsers(completion: @escaping (Bool) -> Void)
    
    func create(entity: PushTokenDTO, completion: @escaping (Int) -> Void)
    
    func read(completion: @escaping (PushTokenDTO?) -> Void)
    
    func deleteTokens(completion: @escaping (Bool) -> Void)
}
