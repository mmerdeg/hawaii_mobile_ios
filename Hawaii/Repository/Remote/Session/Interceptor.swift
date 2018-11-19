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
        
        if TokenUtils.isTokenExpired(token: token) {
            GIDSignIn.sharedInstance()?.signInSilently()
        }
        return ""
    }
}
