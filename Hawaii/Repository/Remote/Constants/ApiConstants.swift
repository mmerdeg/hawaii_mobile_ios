import Foundation

class ApiConstants {
    
    #if PRODUCTION
    static let baseUrl = "https://hawaii2.execom.eu/api"
    static let authHeader = "X-ID-TOKEN"
    #else
    static let baseUrl = "http://10.0.4.195:8090/api"
    static let authHeader = "X-ID-TOKEN"
    #endif
}
