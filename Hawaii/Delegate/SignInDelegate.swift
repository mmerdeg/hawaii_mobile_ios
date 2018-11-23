import Foundation
import GoogleSignIn

extension AppDelegate: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let idToken = user.authentication.idToken else {
                return
        }
        userDetailsUseCase?.setEmail(user.profile.email)
        
        let oldToken = userDetailsUseCase?.getToken()
        
        userDetailsUseCase?.setToken(token: idToken)
        
        let dimension = round(100 * UIScreen.main.scale)
        if let picture = user.profile.imageURL(withDimension: UInt(dimension)) {
            userDetailsUseCase?.setPictureUrl(picture.absoluteString)
        }
        
        if oldToken == nil || !TokenUtils.isTokenExpired(token: oldToken) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.signedIn),
                                            object: nil, userInfo: nil)
        }
    }
}
