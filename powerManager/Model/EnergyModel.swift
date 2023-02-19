//
//  EnergyModel.swift
//  powerManager
//
//  Created by Paul Olphert on 16/02/2023.
//

//used to manage the Api call to the Imperical College Londons Electricity Cost Api
class EnergyModel {
    var overall: Double
    var unixTimestamp: Double
    var timestamp: String
    
    init(overall: Double, unixTimestamp: Double, timestamp: String) {
        self.overall = overall
        self.unixTimestamp = unixTimestamp
        self.timestamp = timestamp
    }
}
