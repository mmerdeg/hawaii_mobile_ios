import Foundation
import Alamofire
import GoogleSignIn
import SwinjectStoryboard
import Swinject

protocol InterceptorProtocol: RequestAdapter {
    func getValidToken() -> String?
}

class Interceptor: InterceptorProtocol {
    
    var signInUseCase: SignInUseCaseProtocol?
    
    init(signInUseCase: SignInUseCaseProtocol) {
        self.signInUseCase = signInUseCase
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest

        let token = getValidToken()
        urlRequest.setValue(token, forHTTPHeaderField: ApiConstants.authHeader)
        
        printRequest(urlRequest: urlRequest)
        
        return urlRequest
    }
    
    func getValidToken() -> String? {
        
        let userDetailsUseCase = SwinjectStoryboard.defaultContainer.resolve(UserDetailsUseCaseProtocol.self,
                                                                         name: String(describing: UserDetailsUseCaseProtocol.self))
        guard let token = userDetailsUseCase?.getToken(),
            let signInUseCase = signInUseCase else {
            return nil
        }
        
        if !TokenUtils.isTokenExpired(token: token) {
            return token
        }
        signInUseCase.refreshToken()
        
        return userDetailsUseCase?.getToken()
    }
    
    func printRequest(urlRequest: URLRequest) {
        guard let url = urlRequest.url else {
            return
        }
        print("""
            *******************************
            REQUEST
            URL: \(String(describing: url))
            METHOD: \(String(describing: urlRequest.httpMethod ?? ""))
            BODY: \(NSString(data: urlRequest.httpBody ?? Data(), encoding: String.Encoding.utf8.rawValue) ?? "")
            HEADERS: \(urlRequest.allHTTPHeaderFields ?? [:])
            *******************************\n
            """
        )
    }
}
