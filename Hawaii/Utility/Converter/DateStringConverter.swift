//
//  DateStringConverter.swift
//  Hawaii
//
//  Created by Server on 10/29/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation

class DateStringConverter {
    
    static func convertDateString(dateString: String, fromFormat sourceFormat: String, toFormat desFormat: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = sourceFormat
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = desFormat
        
        return dateFormatter.string(from: date ?? Date())
    }
}
