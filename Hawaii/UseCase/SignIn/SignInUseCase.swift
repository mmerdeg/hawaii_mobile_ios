import Foundation
import GoogleSignIn

protocol SignInUseCaseProtocol: GIDSignInDelegate {
    
    func initGoogleSignIn()
    
    func refreshToken()
}

class SignInUseCase: NSObject, SignInUseCaseProtocol {

    #if PRODUCTION
    let clientId = "91011414864-fse65f2pje2rgmobdqu8n67ld8pk6mhr.apps.googleusercontent.com"
    #else
    let clientId = "91011414864-9igmd38tpgbklpgkdpcogh9j6h7e2rt9.apps.googleusercontent.com"
    #endif
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    var refreshTokenGroup: DispatchGroup?
    
    init(userDetailsUseCase: UserDetailsUseCaseProtocol, refreshTokenGroup: DispatchGroup) {
        self.userDetailsUseCase = userDetailsUseCase
        self.refreshTokenGroup = refreshTokenGroup
    }
    
    func initGoogleSignIn() {
        GIDSignIn.sharedInstance().clientID = clientId
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func refreshToken() {
        guard let refreshTokenGroup = refreshTokenGroup else {
            return
        }
        refreshTokenGroup.enter()
        
        DispatchQueue.main.async {
            GIDSignIn.sharedInstance()?.signInSilently()
        }
        refreshTokenGroup.wait()
    }
    
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
        
        let isSilentSignIn = oldToken != nil && TokenUtils.isTokenExpired(token: oldToken)
       
        if isSilentSignIn {
            if let refreshTokenGroup = refreshTokenGroup {
                refreshTokenGroup.leave()
            }
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.signedIn),
                                        object: nil, userInfo: nil)
    }
}
