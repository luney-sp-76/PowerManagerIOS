//
//  DeviceManager.swift
//  powerManager
//
//  Created by Paul Olphert on 01/01/2023.
//

import Foundation

protocol DeviceManagerDelegate {
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel)
    func didFailWithError(error: Error)
    
}
//let endPoint = UrlEndpoint.init(batteryLevel: "_battery_level", batteryState: "_battery_state", plugEnergy: "_energy", plugTemperature: "_device_temperature", plugEnergyCost: "_energy_cost", deviceId: [DeviceName(plugName: "0x0015bc002f00edf3", phoneName: "iphone_8_number_1")])

struct DeviceManager {
    
    let homeAssistantFetchUrl = "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/"
    var delegate: DeviceManagerDelegate?
    //call to return the iphone BatteryLevel state (should be an int) used UrlEndPoint Model to form the endpoints
    
    // utility function, can be called for any endpoint "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/states/sensor.devicename-endpoint"
    // returns a DeviceModel from the ApiCall Model
    func fetchDeviceData(deviceName: String, urlEndPoint: String) {
        let urlString = "\(homeAssistantFetchUrl)states/sensor.\(deviceName)\(urlEndPoint)"
        callForData(urlString: urlString)
    }
    
    func callForData(urlString: String) {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmNzI5MGM3OTE0NjE0ODhmOGYzZjFjMDU4YjA2YmRhOSIsImlhdCI6MTY3Mjc1OTk4MCwiZXhwIjoxOTg4MTE5OTgwfQ.X9E2pp6XUxjORMAK_mJSsZK5GG6rv4b-3c8X88eX1yQ"
        
     
        print("is this working?")
        //1: Create a URL
        if let url = URL(string: urlString){
            var urlRequest = URLRequest(url:url)
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "GET"
            
            //2: Create a URLSession
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            print("task 3")
            //3: Give Session a task
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let device = self.parseJSON(safeData){
                        self.delegate?.didUpdateDevice(self, device: device)
                    }
                }
            }
            //4: Start the task
            task.resume()
        }
       
    }
    
    func parseJSON(_ deviceData: Data) -> DeviceModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData =  try decoder.decode(DeviceData.self, from: deviceData)
            let id = decodedData.entity_id
            let state = decodedData.state
            let name = decodedData.attributes[0].friendly_name
            
            let device = DeviceModel(id: id, state: state, name: name)
            
            
            return device
            
        }catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}




