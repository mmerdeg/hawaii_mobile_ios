import Foundation

class ViewConstants {
    #if PRODUCTION
    static let baseUrl = "https://hawaii2.execom.eu"
    #else
    static let baseUrl = "http://10.0.5.142:8080/api"
    #endif
    
    static let dialogBackgroundAlpha = 0.85
    
    static let maxTimeElapsed: Double = 360
    
    static let dateSourceFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    static let halfDayFormat = "%.1f"
}

struct NotificationNames {
    static let refreshData = "refreshData"
    
    static let refreshFirebaseToken = "refreshFirebaseToken"
    
    static let refreshToken = "refreshToken"
}
