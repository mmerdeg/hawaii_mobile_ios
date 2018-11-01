import Foundation

protocol UserDetailsUseCaseProtocol {
    
    func getToken() -> String?
    
    func setToken(token: String)
    
    func removeToken()
    
    func getEmail() -> String?
    
    func setEmail(_ email: String)
    
    func removeEmail()
    
    func getLoadMore() -> Bool
    
    func setLoadMore(_ loadMore: Bool)
    
    func getFirebaseToken() -> String?

    func setFirebaseToken(_ token: String)

}

class UserDetailsUseCase: UserDetailsUseCaseProtocol {

    let userDetailsRepository: UserDetailsRepositoryProtocol!
    
    init(userDetailsRepository: UserDetailsRepositoryProtocol) {
        self.userDetailsRepository = userDetailsRepository
    }
    
    func getToken() -> String? {
        return userDetailsRepository.getToken()
    }
    
    func setToken(token: String) {
        userDetailsRepository.setToken(token: token)
    }
    
    func removeToken() {
        userDetailsRepository.removeToken()
    }
    
    func getEmail() -> String? {
        return userDetailsRepository.getEmail()
    }
    
    func setEmail(_ email: String) {
        userDetailsRepository.setEmail(email)
    }
    
    func removeEmail() {
        userDetailsRepository.removeEmail()
    }
    func getLoadMore() -> Bool {
        return userDetailsRepository.getLoadMore()
    }
    
    func setLoadMore(_ loadMore: Bool) {
        userDetailsRepository.setLoadMore(loadMore)
    }
    
    func getFirebaseToken() -> String? {
        return userDetailsRepository.getFirebaseToken()
    }
    
    func setFirebaseToken(_ token: String) {
        userDetailsRepository.setFirebaseToken(token)
    }

}
