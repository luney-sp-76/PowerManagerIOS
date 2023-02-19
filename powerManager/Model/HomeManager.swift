//
//  HomeManager.swift
//  powerManager
//
//  Created by Paul Olphert on 18/01/2023.

import Foundation
import FirebaseFirestore


protocol HomeManagerDelegate: AnyObject {
    func didReceiveDevices(_ devices: [HomeAssistantData])
}

var delegate: HomeManagerDelegate?

class HomeManager  {
    var deviceArray = [HomeAssistantData]()
    let homeAssistantFetchUrl = K.baseURL
    weak var delegate: HomeManagerDelegate?
    let cache = NSCache<NSString, NSArray>()
   
    
    
    func fetchDeviceData() {
        let urlString = "\(homeAssistantFetchUrl)states"
        if let cachedData = cache.object(forKey: "devices") {
                   self.deviceArray = cachedData as! [HomeAssistantData]
                   delegate?.didReceiveDevices(self.deviceArray)
           //cache.countLimit = 13
            //cache.evictsObjectsWithDiscardedContent = true
                    return
                }
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
                do {
                    
                    let device = try JSONDecoder().decode([HomeAssistantData].self, from: safeData)
                    for item in device {
                        /// sensor is the entity id after the word sensor so it should be contained within the switch entity_id to be added to the array ie sensor.{0x0015bc002f00edf3}_energy
                        //let sensor = AppUtility.selectDeviceFromEntityString(entity: item.entity_id)
                        if item.entity_id.hasSuffix("_energy") || item.entity_id.hasSuffix("_battery_level") || item.entity_id.hasSuffix("_battery_state") || item.entity_id.hasPrefix("switch") {
                                self.deviceArray.append(item)
                        }
                    }
                    self.cache.setObject(self.deviceArray as NSArray, forKey: "devices")
                    DispatchQueue.main.async { [self] in
                                       self.delegate?.didReceiveDevices(self.deviceArray)
                                   }
                } catch {
                    print("JSONDecoder error:", error)
                }
            }
            //4: Start the task
            task.resume()
        }
    }
}



