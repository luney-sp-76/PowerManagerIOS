//
//  DateFormatter.swift
//  powerManager
//
//  Created by Paul Olphert on 05/02/2023.
//

import Foundation
/**
 
 DateFormat is a struct that provides static functions for converting a date string from the Homeassistant API format to a Date object, and vice versa.

 The dateFormatted

 The dateConvert function takes a Date object and returns a string representation of that date in the format used by the Homeassistant API.
 
 */
struct DateFormat {
    
    /**
     
     - Parameters:
      - date string in the format used by the Homeassistant API (yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ)
     - Returns:
      - a Date object representing that date and time. If the string cannot be parsed, the function logs an error message and returns the current date.
     
     */
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
    
    /**
     
     - Parameters:
        -  a Date object
     - Returns:
        - a string representation of that date in the format used by the Homeassistant API
     
     */
    static func dateConvert(inputDate: Date) -> String {
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

        let outputDateString = outputDateFormatter.string(from: inputDate)
        return outputDateString
    }

}







