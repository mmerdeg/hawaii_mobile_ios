//
//  CalendarDateFormatter.swift
//  Hawaii
//
//  Created by Server on 11/5/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class CalendarDateFormatter: DateFormatter {
    
    let format = "dd MM yyyy"
    let zone = TimeZone(abbreviation: "UTC")
    let calendarLocale = Calendar.current.locale
    
    override init() {
        super.init()
        dateFormat = format
        timeZone = zone
        locale = calendarLocale
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
