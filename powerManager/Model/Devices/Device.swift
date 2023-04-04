//
//  Device.swift
//  powerManager
//
//  Created by Paul Olphert on 22/01/2023.
//

import Foundation

/**
 
The Device class is a simple class that represents a HomeAssistant device.
It has a number of properties that represent different aspects of the device, including its ID, state, name, last update time, and UUID.
Additionally, it has a function that sets these properties and returns a DeviceModel object.
 
*/
class Device {
    var id: String = ""
    var state: String = ""
    let name: String = ""
    let lastUpdate: String = ""
    let uuid: String = ""
    
    func setProperties(id: String, state: String, name: String, lastUpdate: String, uuid: String) -> DeviceModel {
        return DeviceModel(id: id, state: state, name: name, lastUpdate: lastUpdate, uuid: uuid)
    }
}
