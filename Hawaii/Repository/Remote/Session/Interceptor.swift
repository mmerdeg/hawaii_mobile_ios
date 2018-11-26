import Foundation
import Alamofire
import GoogleSignIn
import SwinjectStoryboard
import Swinject

class Interceptor: RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        let token = getValidToken()
        urlRequest.setValue(token, forHTTPHeaderField: ApiConstants.authHeader)
        
        return urlRequest
    }
    
    func getValidToken() -> String? {
        
        let userDetailsUseCase = SwinjectStoryboard.defaultContainer.resolve(UserDetailsUseCaseProtocol.self,
                                                                         name: String(describing: UserDetailsUseCaseProtocol.self))
        
        guard let token = userDetailsUseCase?.getToken() else {
            return nil
        }
        
        if !TokenUtils.isTokenExpired(token: token) {
            return token
        }
        
        GIDSignIn.sharedInstance()?.signInSilently()
        return userDetailsUseCase?.getToken()
    }
    
}
