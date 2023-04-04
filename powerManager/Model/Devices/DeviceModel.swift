//
//  DeviceModel.swift
//  powerManager
//
//  Created by Paul Olphert on 02/01/2023.
//

import Foundation

/**
 
The DeviceModel struct represents a HomeAssistant device, with properties for its ID, state, name, last update time, and UUID.
These properties are all immutable, as indicated by the use of the let keyword.
The struct is used to store the data of a device and pass it around between functions.
 
*/
struct DeviceModel {
   
    let id: String
    let state: String
    let name: String
    let lastUpdate: String
    let uuid: String 
}


