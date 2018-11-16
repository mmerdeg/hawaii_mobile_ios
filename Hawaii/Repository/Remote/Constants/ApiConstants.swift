import Foundation

class ApiConstants {
    
    #if PRODUCTION
    static let baseUrl = "https://hawaii2.execom.eu"
    static let authHeader = "X-ID-TOKEN"
    #else
    static let baseUrl = "http://10.0.5.142:8080/api"
    static let authHeader = "X-ID-TOKEN"
    #endif
}
