//
//  ViewUtility.swift
//  Hawaii
//
//  Created by Server on 7/2/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

class ViewUtility {
    
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
        
        let okActionTitle = "OK"
        let cancelActionTitle = "Cancel"
        
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

}
