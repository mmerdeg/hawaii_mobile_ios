import Foundation
import Firebase

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        userDetailsUseCase?.removeFirebaseToken()
        userDetailsUseCase?.setFirebaseToken(fcmToken)
        guard let hasRunBefore = userDetailsUseCase?.hasRunBefore() else {
            return
        }
        if !hasRunBefore {
            userDetailsUseCase?.setRunBefore(true)
            userDetailsUseCase?.removeToken()
        }
        userUseCase?.setFirebaseToken { _ in
            
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}
