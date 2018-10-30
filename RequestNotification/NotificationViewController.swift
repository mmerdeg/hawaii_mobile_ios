//
//  NotificationViewController.swift
//  RequestNotification
//
//  Created by Ivan Divljak on 10/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import Kingfisher
import Swinject
import SwinjectStoryboard
import Alamofire
import CodableAlamofire

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var requestPerson: UILabel!
    
    @IBOutlet weak var requestDuration: UILabel!
    
    @IBOutlet weak var requestDates: UILabel!
    
    @IBOutlet weak var requestNotes: UILabel!
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var requestImageFrame: UIView!
    
    @IBOutlet weak var requestReason: UILabel!
    
    let requestUrl = "https://hawaii2.execom.eu/requests"
    
    let applicationTag = "com.hawaii.keys."
    
    
    let tokenKey = "token"
    
    var requestUseCase: RequestUseCaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        self.view.backgroundColor =  UIColor.cyan
    }
    
    func didReceive(_ notification: UNNotification) {
        guard let requestId = notification.request.content.userInfo["requestId"] as? String else {
            return
        }
        
        let token = getItem(key: tokenKey)
        
        print(notification)
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
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        
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
    
}
