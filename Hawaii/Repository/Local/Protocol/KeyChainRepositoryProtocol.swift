import Foundation

protocol KeyChainRepositoryProtocol {
    
    func getItem(key: String) -> String?
    
    func setItem(key: String, value: String)
    
    func removeItem(key: String)
}
