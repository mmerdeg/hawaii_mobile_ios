import Foundation

class ApiConstants {
    
    #if PRODUCTION
    static let baseUrl = "https://hawaii2.execom.eu"
    static let authHeader = "X-AUTH-TOKEN"
    #else
    static let baseUrl = "http://10.0.0.251:8080"
    static let authHeader = "X-AUTH-TOKEN"
    #endif
}
