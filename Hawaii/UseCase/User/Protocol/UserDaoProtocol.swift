import Foundation

protocol UserDaoProtocol {
    
    func create(entity: User, completion: @escaping (Int) -> Void)
    
    func read(completion: @escaping (User?) -> Void)
}
