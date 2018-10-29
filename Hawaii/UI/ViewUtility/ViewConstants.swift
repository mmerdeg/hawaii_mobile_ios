//
//  ViewConstants.swift
//  Hawaii
//
//  Created by Server on 10/17/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class ViewConstants {
    #if PRODUCTION
    static let baseUrl = "https://hawaii2.execom.eu"
    #else
    static let baseUrl = "http://10.0.5.142:8080"
    #endif
    
    static let dialogBackgroundAlpha = 0.85
    
    static let maxTimeElapsed = 15
    
    static let errorDialogTitle = "Error"
    
    static let requestReasonPlaceholder = "Enter reason for leave"
    
    static let sicknessRequestTitle = "Sickness request"
    
    static let bonusRequestTitle = "Bonus request"
    
    static let leaveRequestTitle = "Leave request"
    
    static let dateSourceFormat = "yyyy-MM-dd'T'HH:mm:ss"
}
