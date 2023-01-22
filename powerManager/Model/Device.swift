//
//  Device.swift
//  powerManager
//
//  Created by Paul Olphert on 22/01/2023.
//

import Foundation

class Device {
    var id: String = ""
    var state: String = ""
    let name: String = ""
    let lastUpdate: String = ""
    let uuid: String = ""
    
    func setProperties(entity_id: String, state: String, name: String, lastUpdate: String, uuid: String) -> DeviceModel {
        return DeviceModel(id: entity_id, state: state, name: name, lastUpdate: lastUpdate, uuid: uuid)
    }
}
