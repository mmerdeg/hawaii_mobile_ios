//
//  TimerApplication.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/16/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

/// Application with timer.
class TimerApplication: UIApplication {
    
    static let ApplicationDidTimeoutNotification = "AppTimeout"
    
    // The timeout in seconds for when to fire the idle timer.
    let timeoutInSeconds: TimeInterval = ViewConstants.maxTimeElapsed
    
    var idleTimer: Timer?
    
    /**
     Resets the timer because there was user interaction.
     */
    func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds, target: self,
                                         selector: #selector(TimerApplication.idleTimerExceeded),
                                         userInfo: nil, repeats: false)
    }
    
    /**
     If the timer reaches the limit as defined in timeoutInSeconds, post notification.
     */
    @objc func idleTimerExceeded() {
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: NotificationNames.refreshData),
                                        object: nil, userInfo: nil)
    }
    
    override func sendEvent(_ event: UIEvent) {
        
        super.sendEvent(event)
        
        if event.type != .touches {
            super.sendEvent(event)
            return
        }
        
        if let touches = event.allTouches {
            for touch in touches.enumerated() {
                if touch.element.phase != .cancelled && touch.element.phase != .ended {
                    self.resetIdleTimer()
                    break
                }
            }
        }
        
    }
    
}
