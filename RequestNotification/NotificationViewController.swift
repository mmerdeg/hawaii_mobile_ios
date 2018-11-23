//
//  NotificationViewController.swift
//  RequestNotification
//
//  Created by Ivan Divljak on 11/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import Kingfisher
import Alamofire
import CodableAlamofire
import ECFoundationiOS

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var requestPerson: UILabel!
    
    @IBOutlet weak var requestDuration: UILabel!
    
    @IBOutlet weak var requestDates: UILabel!
    
    @IBOutlet weak var requestNotes: UILabel!
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var requestImageFrame: UIView!
    
    @IBOutlet weak var requestReason: UILabel!
    
    var request: Request?
    
    let baseUrl = ApiConstants.baseUrl
    
    let requestsUrl =  ApiConstants.baseUrl + "/requests"
    
    let applicationTag = "com.hawaii.keys."
    
    let tokenKey = "token"
    
    #if PRODUCTION
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #else
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        guard let requestDict = notification.request.content.userInfo["request"] as? [String: Any] else {
            return
        }
        
        do {
            let json = try JSONSerialization.data(withJSONObject: requestDict)
            let request = try JSONDecoder().decode(Request.self, from: json)
            guard let notes = request.reason,
                  let imageUrl = request.absence?.iconUrl,
                  let duration = request.days?.first?.duration?.description,
                  let startDate = request.days?.first?.date,
                  let endDate = request.days?.last?.date,
                  let reason = request.absence?.name,
                  let color = request.requestStatus?.backgoundColor,
                  let userFullname = request.user?.fullName else {
                    return
            }
            self.request = request
            requestNotes.text = notes
            requestDuration.text = String(duration)
            requestPerson.text = userFullname
            requestReason.text = reason
            
            let formatter = DisplayedDateFormatter()
            let start = formatter.string(from: startDate)
            let end = formatter.string(from: endDate)
            requestDates.text = start == end ? start : start + " - " + end

            self.view.backgroundColor = UIColor.lightPrimaryColor

            date.text = DateStringConverter.convertDateString(dateString: request.submissionTime ?? "",
                                                              fromFormat: ViewConstants.dateSourceFormat,
                                                              toFormat: formatter.format)

            requestImage.kf.setImage(with: URL(string: baseUrl + "/" + imageUrl))
            requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
            requestImage.tintColor = UIColor.primaryColor
            requestImage.backgroundColor = color
            requestImage.layer.cornerRadius = requestImage.frame.height / 2
            requestImage.layer.masksToBounds = true
            requestImageFrame.backgroundColor = color
            requestImageFrame.layer.cornerRadius = requestImageFrame.frame.height / 2
            requestImageFrame.layer.masksToBounds = true
        
        } catch {
            print(error)
        }
        
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
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "DECLINE_ACTION"
        {
            let status: RequestStatus = request?.requestStatus == .cancelationPending ? .approved: .rejected
            updateRequest(request:  Request(request: request,
                                            requestStatus: status)) { requestResponse in
                                                DispatchQueue.main.async {
                                                    completion(.dismiss)
                                                }
            }
            
        } else if response.actionIdentifier == "ACCEPT_ACTION" {
            let status: RequestStatus = request?.requestStatus == .cancelationPending ? .canceled : .approved
            updateRequest(request:  Request(request: request,
                                            requestStatus: status)) { requestResponse in
                                                DispatchQueue.main.async {
                                                    completion(.dismiss)
                                                }
            }
        } 
    }
    
    func updateRequest(request: Request, completion: @escaping (GenericResponse<Request>) -> Void) {
        guard let url = URL(string: requestsUrl),
              let requestParameters = request.dictionary,
              let token = getItem(key: tokenKey) else {
                return
        }
        print(requestParameters)
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
        Alamofire.request(url, method: .put,
                          parameters: requestParameters,
                          encoding: JSONEncoding.default,
                          headers: getHeaders(token: token)).validate().responseDecodableObject(keyPath: nil,
                                                                                                decoder: getDecoder(),
                                                                                                completionHandler: completionHandler)
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

}
