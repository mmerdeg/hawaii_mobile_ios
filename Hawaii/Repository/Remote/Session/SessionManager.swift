import Foundation
import Alamofire

class SessionManager {
    
    private static let session = Alamofire.SessionManager.default
    
    private static let interceptor = Interceptor()
    
    static func getSession() -> Alamofire.SessionManager {
        session.adapter = interceptor
        return session
    }
}
