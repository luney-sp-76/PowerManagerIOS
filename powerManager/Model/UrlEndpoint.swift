//
//  UrlEndpoint.swift
//  powerManager
//
//  Created by Paul Olphert on 03/01/2023.
//

import Foundation

struct UrlEndpoint {
    
    let batteryLevel: String
    let batteryState : String
    let plugEnergy : String
    let plugTemperature : String
    let plugEnergyCost : String
    let deviceId: [DeviceName]
    
}

struct DeviceName {
    let plugName: String
    let phoneName: String
}




