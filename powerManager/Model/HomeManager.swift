//
//  HomeManager.swift
//  powerManager
//
//  Created by Paul Olphert on 18/01/2023.

import Foundation
import FirebaseFirestore


protocol HomeManagerDelegate {
    func didUpdateDevice(_ homeManager: HomeManager, device: DeviceModel)
    func didFailWithError(error: Error)
}

struct HomeManager  {
    
    
    let homeAssistantFetchUrl = K.baseURL
    var delegate: HomeManagerDelegate?
   
    
   
    // returns a DeviceModel from the ApiCall Model
    func fetchDeviceData() {
        let urlString = "\(homeAssistantFetchUrl)states"
        print(urlString)
        callForData(urlString: urlString)
    }
    
    
    func callForData(urlString: String) {
        let token = K.token
        //1: Create a URL
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url:url)
            
            //2: Create a URLSession
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //3: Give Session a task
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                guard let safeData = data else {return}
                //let dataString = String(data: safeData, encoding: .utf8)
                //print("Response data string:\n \(dataString!)")
                do {
                    let json = try JSONSerialization.jsonObject(with: safeData, options: []) as? [[String: Any]]
                    if let json = json {
                        for item in json {
                            let device = DeviceModel(dictionary: item)
                            print(device.name)
                            print(item)
                            // }
                        }
                    }
        
                    
                } catch {
                    print("JSONSerialization error:", error)
                }
            }
                
                //4: Start the task
                task.resume()
            }
            
        }
    

    
    func parseJSON(_ deviceData: Data) -> DeviceModel? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DeviceData.self, from: deviceData)
            let id = decodedData.entity_id
            let state = decodedData.state
            let name = decodedData.attributes.friendlyName
            let lastUpdate = decodedData.last_updated
            let uuid = decodedData.context.id
            print("device name: \(id)")
            print("friendly name: \(name)")
            print("Unique device ID: \(uuid)")
            print("current state:\(state)")
            print("last updated: \(lastUpdate)")
            print("")
            let device = DeviceModel(id: id, state: state, name: name, lastUpdate: lastUpdate, uuid: uuid)
            return device
            
        } catch {
            self.delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
    
    
}

//MARK: - Dictionary Device Model if needed

extension DeviceModel  {
    init(dictionary: [String : Any]) {
        
        self.id = dictionary["entity_id"] as? String ?? ""
        self.state = dictionary["state"] as? String ?? ""
        self.name = dictionary["attributes[0]friendly_name"] as? String ?? "nah"
        self.lastUpdate = ((dictionary["context.last_updated"] as? String??)! ?? "") ?? ""
        self.uuid = dictionary["context.user_id"] as? String ?? ""
    }
}
