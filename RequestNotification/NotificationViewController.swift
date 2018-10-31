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
    #if PRODUCTION
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #else
    let keychainAccessGroupName = "PH7K4ADL7R.myKeychainGroup1"
    #endif

    let tokenKey = "token"
    
    var requestUseCase: RequestUseCaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        self.view.backgroundColor =  UIColor.cyan
    }
    
    func didReceive(_ notification: UNNotification) {
        guard let requestId = notification.request.content.userInfo["requestId"] as? Int else {
            return
        }
        
    }
    
    
}
