import Foundation
import Alamofire
import GoogleSignIn

class Interceptor: RequestAdapter {
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        guard let userDetailsUseCase = self.userDetailsUseCase else {
            return urlRequest
        }
        let token = getValidToken(token: userDetailsUseCase.getToken())
        urlRequest.setValue(token, forHTTPHeaderField: ApiConstants.authHeader)
        
        return urlRequest
    }
    
    func getValidToken(token: String?) -> String? {
        guard let token = token else {
            return nil
        }
        addObservers()
        
        if TokenUtils.isTokenExpired(token: token) {
            GIDSignIn.sharedInstance()?.signInSilently()
        }
        
        // OVDE SAD TREBA DA CEKAM TOKEN
        return ""
    }
    
    @objc func onTokenRefresh(_ notification: Notification) {
        guard let userDetailsUseCase = self.userDetailsUseCase else {
            return
        }
        let token = userDetailsUseCase.getToken()
        
        // KOJI DOBIJEM OVDE
        
        removeObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onTokenRefresh),
                                               name: NSNotification.Name(rawValue: NotificationNames.refreshToken), object: nil)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.refreshToken), object: nil)
    }
}
