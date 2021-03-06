import Foundation

class KeyChainRepository: KeyChainRepositoryProtocol {
    
    let applicationTag = "com.hawaii.keys."
    #if PRODUCTION
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #else
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #endif
    
    func getItem(key: String) -> String? {
        let getItemQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                            kSecAttrService as String: applicationTag,
                                            kSecAttrAccount as String: key,
                                            kSecAttrAccessGroup as String: keychainAccessGroupName as AnyObject,
                                            kSecMatchLimit as String: kSecMatchLimitOne,
                                            kSecReturnAttributes as String: true,
                                            kSecReturnData as String: true]
        var itemRef: CFTypeRef?
        let status = SecItemCopyMatching(getItemQuery as CFDictionary, &itemRef)
        guard status != errSecItemNotFound else {
            print("Item not found!")
            return nil
        }
        guard status == errSecSuccess else {
            print("Item retrieving failed!")
            return nil
        }
        
        guard let existingItem = itemRef as? [String: Any],
            let itemData = existingItem[kSecValueData as String] as? Data,
            let itemString = String(data: itemData, encoding: String.Encoding.utf8) else {
                return nil
        }
        return itemString
    }
    
    func setItem(key: String, value: String) {
        removeItem(key: key)
        let data = value.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let addItemQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                            kSecAttrService as String: applicationTag,
                                            kSecAttrAccessGroup as String: keychainAccessGroupName as AnyObject,
                                            kSecAttrAccount as String: key,
                                            kSecValueData as String: data ?? ""]
        
        let status = SecItemAdd(addItemQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Item storing failed!")
            return
        }
    }
    
    func removeItem(key: String) {
        let removeItemQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                               kSecAttrService as String: applicationTag,
                                               kSecAttrAccessGroup as String: keychainAccessGroupName as AnyObject,
                                               kSecAttrAccount as String: key]
        let status = SecItemDelete(removeItemQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            print("Item deletion failed!")
            return
        }
    }
}
