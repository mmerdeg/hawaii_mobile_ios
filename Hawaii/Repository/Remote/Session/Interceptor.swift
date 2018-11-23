import Foundation
import Alamofire
import GoogleSignIn
import SwinjectStoryboard
import Swinject

class Interceptor: RequestAdapter {
    
    var userDetailsUseCase = SwinjectStoryboard.defaultContainer.resolve(UserDetailsUseCaseProtocol.self,
                                                                         name: String(describing: UserDetailsUseCaseProtocol.self))
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
        
        if !TokenUtils.isTokenExpired(token: token) {
            return token
        }
        
        GIDSignIn.sharedInstance()?.signInSilently()
        return userDetailsUseCase?.getToken()
    }
    
}
