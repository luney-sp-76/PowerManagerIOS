//
//  DeviceManager.swift
//  powerManager
//
//  Created by Paul Olphert on 01/01/2023.
//

import Foundation
let token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIyMTUwNGRhYTI1NTQ0OGEzOTY2NThkODYyZWJiY2NkMCIsImlhdCI6MTY3MjE1MTY0MiwiZXhwIjoxOTg3NTExNjQyfQ.MNmgTZHOZO7eEO4wywzqrfdma1O-QsRyjd7nQVtUNew"
var endPoint = UrlEndpoint.init(batteryLevel: "_battery_level", batteryState: "_battery_state", plugEnergy: "_energy", plugTemperature: "_device_temperature", plugEnergyCost: "_energy_cost", deviceId: [DeviceName(plugName: "0x0015bc002f00edf3", phoneName: "_8_number_1")])

protocol DeviceManagerDelegate {
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel)
    func didFailWithError(error:Error)
}

struct DeviceManager {
    let homeAssistantFetchUrl = "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/"
    let homeAssistantPlugState = "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/states/"
    var delegate: DeviceManagerDelegate?
    
    func fetchDeviceData(deviceName: UrlEndpoint, endPoint: UrlEndpoint){
        let urlString = "\(homeAssistantFetchUrl)states/sensor.\(deviceName)\(endPoint)"
        performRequest(with: urlString)
    }
    func fetchPlugState(deviceName: UrlEndpoint) {
        let urlString = "\(homeAssistantFetchUrl)states/switch.\(deviceName)"
        performRequest(with: urlString)
    }
   
   
    func performRequest(with urlString: String) {
        //1: Create a URL
        if let url = URL(string: urlString){
            
            //2: Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3: Give Session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    //parse data (use self if its calling a method from the current class
                    if let device = self.parseJSON(safeData) {
                        //implementing the delegate pattern to send DeviceModel data to DeviceViewController
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
            
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
