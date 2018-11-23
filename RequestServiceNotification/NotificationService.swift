//
//  NotificationService.swift
//  RequestServiceNotification
//
//  Created by Ivan Divljak on 11/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UserNotifications
import Alamofire
import CodableAlamofire

import ECFoundationiOS

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    let applicationTag = "com.hawaii.keys."
    
    let requestUrl = ApiConstants.baseUrl + "/requests"
    
    let tokenKey = "token"
    
    #if PRODUCTION
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #else
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #endif

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        print(request.content.userInfo)
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            guard let requestIdString = request.content.userInfo["requestId"] as? String,
                  let requestId = Int(requestIdString),
                  let token = getItem(key: tokenKey) else {
                return
            }
            getBy(id: requestId, token: token) { requestResponse in
                guard let success = requestResponse.success else {
                    return
                }
                
                if success {
                    guard let requestObject = requestResponse.item else {
                        return
                    }
                    bestAttemptContent.userInfo = ["request": (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(requestObject))) as? [String: Any] ?? [:],
                                                   "aps": request.content.userInfo["aps"] ?? [:],
                                                   "requestStatus": request.content.userInfo["requestStatus"] ?? [:]]
                }
                contentHandler(bestAttemptContent)
            }
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
        return [ApiConstants.authHeader: token]
    }
    
    func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getDateFormatter())
        return decoder
    }
    
    func getDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
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
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
