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
//let endPoint = UrlEndpoint.init(batteryLevel: "_battery_level", batteryState: "_battery_state", plugEnergy: "_energy", plugTemperature: "_device_temperature", plugEnergyCost: "_energy_cost", deviceId: [DeviceName(plugName: "0x0015bc002f00edf3", phoneName: "iphone_8_number_1")])

struct DeviceManager {
   
    let homeAssistantFetchUrl = "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/"
    var delegate: DeviceManagerDelegate?
    //call to return the iphone BatteryLevel state (should be an int) used UrlEndPoint Model to form the endpoints
    
    // utility function, can be called for any endpoint "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/states/sensor.devicename-endpoint"
    // returns a DeviceModel from the ApiCall Model
    func fetchDeviceData(deviceName: String, urlEndPoint: String) {
        let urlString = "\(homeAssistantFetchUrl)states/sensor.iphone_8_number_1_battery_level"
        let device = callForData(urlString: urlString)
        self.delegate?.didUpdateDevice(self, device: device)
    }
    
    func callForData(urlString: String) -> DeviceModel {
        let token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmNzI5MGM3OTE0NjE0ODhmOGYzZjFjMDU4YjA2YmRhOSIsImlhdCI6MTY3Mjc1OTk4MCwiZXhwIjoxOTg4MTE5OTgwfQ.X9E2pp6XUxjORMAK_mJSsZK5GG6rv4b-3c8X88eX1yQ"
        
        var device = DeviceModel(id:"none",state:"none",name:"none")
        print("is this working?")
        //1: Create a URL
        if let url = URL(string: urlString){
            var urlRequest = URLRequest(url:url)
            urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "GET"
            
            //2: Create a URLSession
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            print("task 3")
            //3: Give Session a task
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                guard error == nil else {
                    print("error calling GET on /todos/1")
                    print(error!)
                    return
                }
                guard let safeData = data
                else {
                    print("error: did not receive data")
                    return
                }
                
                do {
                    //decode all the data requied for the app to read battery level charging state
                    let decodedData = try JSONDecoder().decode(DeviceData.self, from:safeData)
                    
                    let id = decodedData.entity_id
                    let state = decodedData.state
                    let name = decodedData.attributes[0].friendly_name
                    
                    device = DeviceModel(id: id, state: state, name: name)
                    
                    
                } catch {
                    print(error)
                    return
                }
            }
            //4: Start the task
            task.resume()
        }
        return device
    }
    
    
}




