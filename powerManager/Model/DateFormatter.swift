//
//  DateFormatter.swift
//  powerManager
//
//  Created by Paul Olphert on 05/02/2023.
//

import Foundation

struct DateFormat {
    static func dateFormatted(date: String) -> Date {
           
        let timestampString = date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        if let timestamp = formatter.date(from: timestampString){
            let interval = timestamp.timeIntervalSince1970
            let reverseTimestamp = Date(timeIntervalSince1970: interval)
            return reverseTimestamp
           } else {
               print("Unable to parse date string: \(date)")
           }
        return Date()
       }
}
