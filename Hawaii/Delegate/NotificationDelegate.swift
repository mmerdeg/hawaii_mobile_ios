import Foundation
import UserNotifications
import NotificationBannerSwift

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let aps = notification.request.content.userInfo["aps"] as? [String: Any],
            let alert = aps["alert"] as? [String: Any],
            let body = alert["body"] as? String,
            let title = alert["title"] as? String else {
                return
        }
        print(notification.request.content.userInfo)
        if aps["category"] != nil {
            let banner = NotificationBanner(title: title, subtitle: body, style: .info)
            banner.show()
            userDetailsUseCase?.setRefreshApproveScreen(true)
        } else {
            guard let requestStatus = notification.request.content.userInfo["requestStatus"] as? String else {
                return
            }
            
            let status = RequestStatus(rawValue: requestStatus) ?? RequestStatus.rejected
            
            switch status {
            case .approved:
                let banner = NotificationBanner(title: title, subtitle: body, style: .success)
                banner.show()
            case .rejected:
                let banner = NotificationBanner(title: title, subtitle: body, style: .danger)
                banner.show()
            case .pending:
                let banner = NotificationBanner(title: title, subtitle: body, style: .warning)
                banner.show()
            default:
                let banner = NotificationBanner(title: title, subtitle: body, style: .info)
                banner.show()
            }
            
        }
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: NotificationNames.refreshData),
                                        object: nil, userInfo: nil)
        completionHandler([.badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler()
    }
}
