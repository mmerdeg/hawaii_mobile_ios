import Foundation
import JWTDecode

class TokenUtils {
    
    static func isTokenExpired(token: String?) -> Bool {
        guard let token = token else {
            return true
        }
        do {
            let jwt = try decode(jwt: token)
            return jwt.expired
        } catch {
            return true
        }
    }
}
