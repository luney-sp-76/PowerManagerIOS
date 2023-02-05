//
//  HomeData.swift
//  powerManager
//
//  Created by Paul Olphert on 30/01/2023.
//

import Foundation


struct HomeData {
    let user: String
    let entity_id: String
    let state: String
    let lastUpdated: String
    let friendlyName: String
    let uuid: String

    // Computed property to create a Date object from the lastUpdated string
       var date: Date {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
           return dateFormatter.date(from: lastUpdated)!
       }
}
