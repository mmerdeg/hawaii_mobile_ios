import Foundation

class RefreshUtils {
    
    static func shouldRefreshData(_ lastTimeSynced: Date?) -> Bool {
        let components = Calendar.current.dateComponents([.second], from: lastTimeSynced ?? Date(), to: Date())
        let seconds = components.second ?? 4000
        return seconds >= 4000
    }
}
