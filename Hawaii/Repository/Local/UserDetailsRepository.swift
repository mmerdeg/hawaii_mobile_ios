import Foundation

class UserDetailsRepository: UserDetailsRepositoryProtocol {
    
    var keyChainRepository: KeyChainRepositoryProtocol?
    
    let userDefaults = UserDefaults.standard
    
    let tokenKey = "token"
    
    let emailKey = "email"
    
    let loadMoreKey = "loadMore"
    
    let firebaseTokenKey = "firebaseToken"
    
    let pictureUrlKey = "pictureUrl"
    
    let hasRunBeforeKey = "hasRunBefore"
    
    let doesApproveScreenNeedsRefreshKey = "doesApproveScreenNeedsRefresh"
    
    init(keyChainRepository: KeyChainRepositoryProtocol) {
        self.keyChainRepository = keyChainRepository
    }
    
    func getToken() -> String? {
        return keyChainRepository?.getItem(key: tokenKey)
    }
    
    func setToken(token: String) {
        keyChainRepository?.setItem(key: tokenKey, value: token)
    }
    
    func getFirebaseToken() -> String? {
        return keyChainRepository?.getItem(key: firebaseTokenKey)
    }
    
    func setFirebaseToken(_ token: String) {
        keyChainRepository?.setItem(key: firebaseTokenKey, value: token)
    }
    
    func removeToken() {
        keyChainRepository?.removeItem(key: tokenKey)
    }
    
    func removeFirebaseToken() {
        keyChainRepository?.removeItem(key: firebaseTokenKey)
    }
    
    func getEmail() -> String? {
        return keyChainRepository?.getItem(key: emailKey)
    }
    
    func setEmail(_ email: String) {
        keyChainRepository?.setItem(key: emailKey, value: email)
    }
    
    func removeEmail() {
        keyChainRepository?.removeItem(key: emailKey)
    }
    
    func getPictureUrl() -> String? {
        var pictureUrl: String?
        if userDefaults.object(forKey: pictureUrlKey) != nil {
            pictureUrl = userDefaults.string(forKey: pictureUrlKey)
        }
        return pictureUrl
    }
    
    func setPictureUrl(_ pictureUrl: String) {
        userDefaults.set(pictureUrl, forKey: pictureUrlKey)
        userDefaults.synchronize()
    }
    
    func getLoadMore() -> Bool {
        var loadMore = false
        if userDefaults.object(forKey: loadMoreKey) != nil {
            loadMore = userDefaults.bool(forKey: loadMoreKey)
        }
        return loadMore
    }
    
    func setLoadMore(_ loadMore: Bool) {
        userDefaults.set(loadMore, forKey: loadMoreKey)
        userDefaults.synchronize()
    }
    
    func hasRunBefore() -> Bool {
        var hasRunBefore = false
        if userDefaults.object(forKey: hasRunBeforeKey) != nil {
            hasRunBefore = userDefaults.bool(forKey: hasRunBeforeKey)
        }
        return hasRunBefore
    }
    
    func setRunBefore(_ hasRunBefore: Bool) {
        userDefaults.set(hasRunBefore, forKey: hasRunBeforeKey)
        userDefaults.synchronize()
    }
    
    func setRefreshApproveScreen(_ doesApproveScreenNeedsRefresh: Bool) {
        userDefaults.set(doesApproveScreenNeedsRefresh, forKey: doesApproveScreenNeedsRefreshKey)
        userDefaults.synchronize()
    }
    
    func doesApproveScreenNeedsRefresh() -> Bool {
        var doesApproveScreenNeedsRefresh = false
        if userDefaults.object(forKey: doesApproveScreenNeedsRefreshKey) != nil {
            doesApproveScreenNeedsRefresh = userDefaults.bool(forKey: doesApproveScreenNeedsRefreshKey)
        }
        return doesApproveScreenNeedsRefresh
    }
    
}
