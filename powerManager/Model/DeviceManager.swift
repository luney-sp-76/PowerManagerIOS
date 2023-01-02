//
//  DeviceManager.swift
//  powerManager
//
//  Created by Paul Olphert on 01/01/2023.
//

import Foundation

protocol DeviceManagerDelegate {
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel)
    func didFailWithError(error:Error)
}

struct DeviceManager {
    let deviceUrl = ""
    var delegate: DeviceManagerDelegate?
    
    func fetchDevice(iphoneName: String){
        let urlString = ""
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
