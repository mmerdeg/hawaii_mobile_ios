import Foundation
import JWTDecode

extension JWT {
    
    var expiration: Date? {
        return claim(name: "exp").date
    }
}
