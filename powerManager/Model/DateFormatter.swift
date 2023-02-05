//
//  DateFormatter.swift
//  powerManager
//
//  Created by Paul Olphert on 05/02/2023.
//

import Foundation

struct DateFormat {
    static func dateFormatted(date: String) -> String {
           
           let dateFormat = ISO8601DateFormatter()
           if let dateString = dateFormat.date(from: date) {
               print("Input date string: \(date)")
               print("Parsed date: \(dateString)")
               let formatter = DateFormatter()
               formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
               return formatter.string(from: dateString)
           } else {
               print("Unable to parse date string: \(date)")
           }
           return " "
       }
}
