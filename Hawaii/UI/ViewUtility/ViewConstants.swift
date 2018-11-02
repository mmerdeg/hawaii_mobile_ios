import Foundation

class ViewConstants {
    #if PRODUCTION
    static let baseUrl = "https://hawaii2.execom.eu"
    #else
    static let baseUrl = "http://10.0.5.142:8080"
    #endif
    
    static let dialogBackgroundAlpha = 0.85
    
    static let maxTimeElapsed = 15
    
    static let dateSourceFormat = "yyyy-MM-dd'T'HH:mm:ss"
}

struct NotificationNames {
    static let refreshData = "refreshData"
}
