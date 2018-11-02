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

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var requestPerson: UILabel!
    
    @IBOutlet weak var requestDuration: UILabel!
    
    @IBOutlet weak var requestDates: UILabel!
    
    @IBOutlet weak var requestNotes: UILabel!
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var requestImageFrame: UIView!
    
    @IBOutlet weak var requestReason: UILabel!
    
    let baseUrl = "https://hawaii2.execom.eu"
    
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
                let status = request.requestStatus,
                let userFullname = request.user?.fullName else {
                    return
            }
            
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

}
