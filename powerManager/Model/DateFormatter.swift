//
//  DateFormatter.swift
//  powerManager
//
//  Created by Paul Olphert on 05/02/2023.
//

import Foundation
// foramts the timestamp from homeassistant into a Date
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
    
    ///convert a standard date format to compare to Homeassistants
    static func dateConvert(inputDate: Date) -> String {
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

        let outputDateString = outputDateFormatter.string(from: inputDate)
        return outputDateString
    }

}







