import Foundation
import UIKit
import EKBlurAlert

class AlertPresenter {
    
    static let titleKey = "attributedTitle"
    
    static let messageKey = "attributedMessage"
    
    static let imageKey = "image"
    
    /**
     Presents alert with custom number of actions.
     
     - Parameter controller:  Alert parent controller.
     - Parameter choices:     List of choices of alert dialogue.
     - Parameter title:       Alert's title.
     - Parameter message:     Alert's message.
     - Parameter completion:  Callback function that sends which button was clicked.
     
     */
    static func showCustomDialog(_ controller: UIViewController,
                                 choices: [DialogWrapper],
                                 title: String? = nil,
                                 message: String? = nil, textAligment: NSTextAlignment? = nil) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAligment ?? .center
        let mutableStringTitle = NSMutableAttributedString(string: title ?? "", attributes: [NSAttributedStringKey.font: UIFont.primary()])
        let mutableStringMessage = NSMutableAttributedString(string: message ?? "",
                                                             attributes: [NSAttributedStringKey.font: UIFont.primary(),
                                                                          NSAttributedStringKey.paragraphStyle: paragraphStyle])
        let dialogue = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        dialogue.view.tintColor = UIColor.primaryColor
        dialogue.setValue(mutableStringTitle, forKey: titleKey)
        if message != nil {
            dialogue.setValue(mutableStringMessage, forKey: messageKey)
        }
        for choice in choices {
            guard let title = choice.title,
                let uiAction = choice.uiAction else {
                    return
            }
            let action = UIAlertAction(title: title, style: uiAction, handler: choice.handler)
            if let image = choice.image {
                action.setValue(image, forKey: imageKey)
            }
            
            dialogue.addAction(action)
        }
        DispatchQueue.main.async {
            controller.present(dialogue, animated: true, completion: nil)
        }
    }
    
    /**
     Show alert with ok button, optional cancel button and action.
     
     - Parameter title:          Alert title.
     - Parameter message:        Alert message.
     - Parameter cancelable:     If true, alert has a cancel button.
     - Parameter viewController: Alert's owner.
     
     */
    static func showAlertWithAction(title: String, message: String,
                                    cancelable: Bool? = false, viewController: UIViewController,
                                    completion: @escaping (Bool) -> Void ) {
        
        let okActionTitle = LocalizedKeys.General.ok.localized()
        let cancelActionTitle = LocalizedKeys.General.cancel.localized()
        
        let mutableStringTitle = NSMutableAttributedString(string: title, attributes: [NSAttributedStringKey.font: UIFont.primary()])
        let mutableStringMessage = NSMutableAttributedString(string: message ,
                                                             attributes: [NSAttributedStringKey.font: UIFont.primary()])
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.setValue(mutableStringTitle, forKey: titleKey)
        alert.setValue(mutableStringMessage, forKey: messageKey)
        
        if cancelable ?? false {
            let okAction = UIAlertAction(title: okActionTitle, style: UIAlertActionStyle.default) { _ in
                completion(true)
            }
            alert.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: UIAlertActionStyle.cancel) { _ in
                completion(false)
            }
            alert.addAction(cancelAction)
        } else {
            let okAction = UIAlertAction(title: okActionTitle, style: UIAlertActionStyle.cancel) { _ in
                completion(true)
            }
            alert.addAction(okAction)
        }
        alert.view.tintColor = UIColor.primaryColor
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /**
     Show alert with yes and no button.
     
     - Parameter title:          Alert title.
     - Parameter message:        Alert message.
     - Parameter viewController: Alert's owner.
     
     */
    static func showAlertWithYesNoAction(title: String, message: String,
                                         viewController: UIViewController,
                                         completion: @escaping (Bool) -> Void ) {
        
        let yesActionTitle = LocalizedKeys.General.yes.localized()
        let noActionTitle = LocalizedKeys.General.no.localized()
        
        let mutableStringTitle = NSMutableAttributedString(string: title, attributes: [NSAttributedStringKey.font: UIFont.primary()])
        let mutableStringMessage = NSMutableAttributedString(string: message ,
                                                             attributes: [NSAttributedStringKey.font: UIFont.primary()])
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.setValue(mutableStringTitle, forKey: titleKey)
        alert.setValue(mutableStringMessage, forKey: messageKey)
        
        let yesAction = UIAlertAction(title: yesActionTitle, style: UIAlertActionStyle.default) { _ in
            completion(true)
        }
        alert.addAction(yesAction)
        
        let noAction = UIAlertAction(title: noActionTitle, style: UIAlertActionStyle.cancel) { _ in
            completion(false)
        }
        alert.addAction(noAction)

        alert.view.tintColor = UIColor.primaryColor
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func presentBluredAlertView(view: UIView, message: String) {
        let imageName = "success"
        let successTitle = LocalizedKeys.General.success.localized()
        
        let alertView = EKBlurAlertView(frame: view.bounds)
        let myImage = UIImage(named: imageName) ?? UIImage()
        alertView.setCornerRadius(10)
        alertView.set(autoFade: true, after: 2)
        alertView.set(image: myImage)
        alertView.set(headline: successTitle)
        alertView.set(subheading: message)
        view.addSubview(alertView)
    }

}
