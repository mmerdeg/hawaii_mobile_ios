import Foundation

class ApiConstants {
    
    #if PRODUCTION
    static let baseUrl = "https://hawaii2.execom.eu/api"
    #else
    static let baseUrl = "http://10.0.4.195:8080/api"
    #endif
    
    static let authHeader = "X-ID-TOKEN"
}
