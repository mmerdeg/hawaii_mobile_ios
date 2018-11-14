import Foundation

class RefreshUtils {
    
    static func shouldRefreshData(_ lastTimeSynced: Date?) -> Bool {
        let components = Calendar.current.dateComponents([.second], from: lastTimeSynced ?? Date(), to: Date())
        let seconds = components.second ?? ViewConstants.maxTimeElapsed
        return seconds >= ViewConstants.maxTimeElapsed
    }
}
