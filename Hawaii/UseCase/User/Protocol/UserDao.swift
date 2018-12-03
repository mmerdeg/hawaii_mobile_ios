import Foundation

protocol UserDao {
    
    func create(entity: User, completion: @escaping (Int) -> Void)
    
    func read(completion: @escaping (User?) -> Void)
    
    func emptyUsers(completion: @escaping (Bool) -> Void)
    
    func create(entity: PushTokenDTO, userId: Int, completion: @escaping (Int) -> Void)
    
    func create(entity: [PushTokenDTO], userId: Int, completion: @escaping (Int) -> Void)
    
    func read(userId: Int, completion: @escaping ([PushTokenDTO]?) -> Void)
    
    func deleteTokens(completion: @escaping (Bool) -> Void)
    
    func deleteToken(pushToken: String, completion: @escaping (Bool) -> Void)
    
    func read(pushToken: String, completion: @escaping (PushTokenDTO?) -> Void)
    
}
