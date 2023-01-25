//
//  HomeManager.swift
//  powerManager
//
//  Created by Paul Olphert on 18/01/2023.

import Foundation
import FirebaseFirestore


protocol HomeManagerDelegate: AnyObject {
    func didReceiveDevices(_ devices: [String])
}

var delegate: HomeManagerDelegate?

class HomeManager  {
    var deviceArray = [String]()
    let homeAssistantFetchUrl = K.baseURL
    weak var delegate: HomeManagerDelegate?
    
    
    func fetchDeviceData() {
        let urlString = "\(homeAssistantFetchUrl)states"
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
                        self.deviceArray.append(item.entity_id)
                    }
                    self.delegate?.didReceiveDevices(self.deviceArray)
                } catch {
                    print("JSONDecoder error:", error)
                }
            }
            //4: Start the task
            task.resume()
        }
    }
}



