//
//  PushTokenViewController.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/30/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class PushTokenViewController: UIViewController {
    
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceNameValue: UILabel!
    
    @IBOutlet weak var platform: UILabel!
    @IBOutlet weak var platformValue: UILabel!
    
    @IBOutlet weak var token: UILabel!
    @IBOutlet weak var tokenValue: UILabel!
    
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var createdDateValue: UILabel!
    
    @IBOutlet weak var platformImageView: RoundedImageView!
    var pushToken: PushTokenDTO?

    override func viewDidLoad() {
        super.viewDidLoad()
        let androidImage = #imageLiteral(resourceName: "android").withRenderingMode(.alwaysTemplate)
        let iOSImage = #imageLiteral(resourceName: "apple").withRenderingMode(.alwaysTemplate)
        platformImageView.image = pushToken?.platform == Platform.iOS ? iOSImage : androidImage
        platformImageView.tintColor = UIColor.primaryTextColor
        deviceName.text = LocalizedKeys.Token.deviceName.localized()
        platform.text = LocalizedKeys.Token.platform.localized()
        createdDate.text = LocalizedKeys.Token.createdDate.localized()
        token.text = LocalizedKeys.Token.notificationToken.localized()
        
        deviceNameValue.text = pushToken?.name
        platformValue.text = pushToken?.platform?.description
        createdDateValue.text = pushToken?.platform?.rawValue
        tokenValue.text = String(describing: pushToken?.pushTokenId ?? -1)
        self.view.backgroundColor = UIColor.primaryColor
    }

}
