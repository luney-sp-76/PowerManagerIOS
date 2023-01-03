//
//  DeviceManager.swift
//  powerManager
//
//  Created by Paul Olphert on 01/01/2023.
//

import Foundation

protocol DeviceManagerDelegate {
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel)
    
}

let token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmNzI5MGM3OTE0NjE0ODhmOGYzZjFjMDU4YjA2YmRhOSIsImlhdCI6MTY3Mjc1OTk4MCwiZXhwIjoxOTg4MTE5OTgwfQ.X9E2pp6XUxjORMAK_mJSsZK5GG6rv4b-3c8X88eX1yQ"

let endPoint = UrlEndpoint.init(batteryLevel: "_battery_level", batteryState: "_battery_state", plugEnergy: "_energy", plugTemperature: "_device_temperature", plugEnergyCost: "_energy_cost", deviceId: [DeviceName(plugName: "0x0015bc002f00edf3", phoneName: "_8_number_1")])


struct DeviceManager {
    let homeAssistantFetchUrl = "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/"
    let homeAssistantPlugState = "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/states/"
    var delegate: DeviceManagerDelegate?
    
    //call to return the iphone BatteryLevel state (should be an int) used UrlEndPoint Model to form the endpoints
    func updateIphoneBatteryLevel(){
        let device = fetchDeviceData(deviceName: endPoint.deviceId[0].phoneName, urlEndPoint: endPoint.batteryLevel)
        self.delegate?.didUpdateDevice(self, device: device!)
    }
    
    // utility function, can be called for any endpoint "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/states/sensor.devicename-endpoint"
    // returns a DeviceModel from the ApiCall Model
    func fetchDeviceData(deviceName: String, urlEndPoint: String) -> DeviceModel? {
        let urlString = "\(homeAssistantFetchUrl)states/sensor.\(deviceName)\(urlEndPoint)"
        let device = ApiCall().callForData(urlString: urlString)
        return device
    }
//    func fetchPlugState(plugName: UrlEndpoint) {
//        let urlString = "\(homeAssistantFetchUrl)states/switch.\(plugName)"
//        performRequest(urlString)
//    }
   
}


