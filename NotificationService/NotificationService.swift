//
//  NotificationService.swift
//  NotificationService
//
//  Created by Ivan Divljak on 10/31/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UserNotifications
import Alamofire
import CodableAlamofire

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    let requestUrl = "https://hawaii2.execom.eu/requests"
    
    let applicationTag = "com.hawaii.keys."
    #if PRODUCTION
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #else
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #endif
    
    let tokenKey = "token"

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            contentHandler(bestAttemptContent)
        }
    }
    
    func getBy(id: Int, token: String, completion: @escaping (GenericResponse<Request>) -> Void) {
        guard let url = URL(string: requestUrl + "/\(id)") else {
            return
        }
        let completionHandler: (_ response: DataResponse<Request>) -> Void = { (response: DataResponse<Request>) in
            switch response.result {
            case .success:
                completion(GenericResponse<Request> (success: true, item: response.result.value,
                                                     statusCode: response.response?.statusCode, error: nil, message: nil))
            case .failure(let error):
                print(error)
                completion(GenericResponse<Request> (success: false, item: nil, statusCode: response.response?.statusCode,
                                                     error: error,
                                                     message: response.error?.localizedDescription))
            }
        }
        Alamofire.request(url, method: .get, headers: getHeaders(token: token)).validate().responseDecodableObject(keyPath: nil,
                                                                                                                   decoder: getDecoder(),
                                                                                                                   completionHandler: completionHandler)
    }
    
    func convertDateString(dateString: String, fromFormat sourceFormat: String, toFormat desFormat: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = sourceFormat
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = desFormat
        
        return dateFormatter.string(from: date ?? Date())
    }
    
    func getHeaders(token: String) -> HTTPHeaders {
        let authHeader = "X-AUTH-TOKEN"
        return [authHeader: token]
    }
    
    func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getDateFormatter())
        return decoder
    }
    
    func getDateFormatter() -> DateFormatter {
        return DateFormatter()
    }
    
    func getItem(key: String) -> String {
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
            return ""
        }
        guard status == errSecSuccess else {
            print("Item retrieving failed!")
            return ""
        }
        
        guard let existingItem = itemRef as? [String: Any],
            let itemData = existingItem[kSecValueData as String] as? Data,
            let itemString = String(data: itemData, encoding: String.Encoding.utf8) else {
                return ""
        }
        return itemString
    }
    
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
