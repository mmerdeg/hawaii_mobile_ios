import Foundation

protocol UserDetailsRepositoryProtocol {
    
    func getToken() -> String?
    
    func setToken(token: String)
    
    func removeToken()
    
    func getEmail() -> String?
    
    func setEmail(_ email: String)
    
    func removeEmail()
    
    func getLoadMore() -> Bool
    
    func setLoadMore(_ loadMore: Bool)
    
    func getPictureUrl() -> String?
    
    func setPictureUrl(_ pictureUrl: String)
    
    func getFirebaseToken() -> String?
    
    func setFirebaseToken(_ token: String)
    
    func removeFirebaseToken()

}
