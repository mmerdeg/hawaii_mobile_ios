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
        dialogue.setValue(mutableStringTitle, forKey: "attributedTitle")
        if message != nil {
            dialogue.setValue(mutableStringMessage, forKey: "attributedMessage")
        }
        for choice in choices {
            guard let title = choice.title,
                let uiAction = choice.uiAction else {
                    return
            }
            let action = UIAlertAction(title: title, style: uiAction, handler: choice.handler)
            if let image = choice.image {
                action.setValue(image, forKey: "image")
            }
            
            dialogue.addAction(action)
        }
        DispatchQueue.main.async {
            controller.present(dialogue, animated: true, completion: nil)
        }
    }
}
