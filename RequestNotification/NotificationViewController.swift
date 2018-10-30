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

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var requestPerson: UILabel!
    
    @IBOutlet weak var requestDuration: UILabel!
    
    @IBOutlet weak var requestDates: UILabel!
    
    @IBOutlet weak var requestNotes: UILabel!
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var requestImageFrame: UIView!
    
    @IBOutlet weak var requestReason: UILabel!
    
    var requestUseCase: RequestUseCaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        self.view.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.2039215686, alpha: 1)
    }
    
    func didReceive(_ notification: UNNotification) {
        
        
    }
    
    
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
//        guard let requestId = notification.request.content.userInfo["requestId"] as? Int else {
//            return
//        }
        requestUseCase?.getBy(id: 14, completion: { requestResponse in
            guard let success = requestResponse.success else {
                return
            }
            if success {
                guard let request = requestResponse.item,
                    let notes = request.reason,
                    let imageUrl = request.absence?.iconUrl,
                    let duration = request.days?.first?.duration?.description,
                    let startDate = request.days?.first?.date,
                    let endDate = request.days?.last?.date,
                    let reason = request.absence?.name,
                    let color = request.requestStatus?.backgoundColor,
                    let status = request.requestStatus,
                    let userFullname = request.user?.fullName else {
                        return
                }
                
                self.date.text = "submission date"
                self.requestNotes.text = notes
                self.requestDuration.text = String(duration)
                self.requestPerson.text = userFullname
                self.requestReason.text = reason
                
                let formatter = DisplayedDateFormatter()
                let start = formatter.string(from: startDate)
                let end = formatter.string(from: endDate)
                self.requestDates.text = start == end ? start : start + " - " + end
                self.view.backgroundColor = UIColor.lightPrimaryColor
                self.date.text = self.convertDateString(dateString: request.submissionTime ?? "",
                                                        fromFormat: "yyyy-MM-dd'T'HH:mm:ss",
                                                        toFormat: "dd.MM.yyyy.")
                
                self.requestImage.kf.setImage(with: URL(string: ViewConstants.baseUrl + "/" + imageUrl))
                self.requestImage.image = self.requestImage.image?.withRenderingMode(.alwaysTemplate)
                self.requestImage.tintColor = UIColor.primaryColor
                self.requestImage.backgroundColor = color
                self.requestImage.layer.cornerRadius = self.requestImage.frame.height / 2
                self.requestImage.layer.masksToBounds = true
                self.requestImageFrame.backgroundColor = color
                self.requestImageFrame.layer.cornerRadius = self.requestImageFrame.frame.height / 2
                self.requestImageFrame.layer.masksToBounds = true
            }
        })
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

}
