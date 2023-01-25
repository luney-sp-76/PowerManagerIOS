//
//  HomeManager.swift
//  powerManager
//
//  Created by Paul Olphert on 18/01/2023.

import Foundation
import FirebaseFirestore
var deviceArray = [HomeAssistantData]()

protocol HomeManagerDelegate: AnyObject {
    func didReceiveDevices(_ devices: [HomeAssistantData])
}

var delegate: HomeManagerDelegate?

struct HomeManager  {
    
    let homeAssistantFetchUrl = K.baseURL
    weak var delegate: HomeManagerDelegate?
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
                do {
                    let device = try JSONDecoder().decode([HomeAssistantData].self, from: safeData)
                    delegate?.didReceiveDevices(device)
                    for item in device {
                        updatedeviceArray(data: item)
                        print(item.entity_id)
                        print(deviceArray.count)
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

func updatedeviceArray(data: HomeAssistantData){
    deviceArray.append(data)
}
