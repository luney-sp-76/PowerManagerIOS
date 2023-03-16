//
//  HomeManager.swift
//  powerManager
//
//  Created by Paul Olphert on 18/01/2023.

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol HomeManagerDelegate: AnyObject {
    func didReceiveDevices(_ devices: [HomeAssistantData])
    func didFailToFetchDeviceData(with: Error)
}



class HomeManager  {
    var deviceArray = [HomeAssistantData]()
    let securedData = SecuredDataFetcher()
    weak var delegate: HomeManagerDelegate?
    let cache = NSCache<NSString, NSArray>()
    let email = Auth.auth().currentUser?.email
   

    init() {
       
        securedData.fetchSecureData(for: email!, password: K.decrypt) { url, token, error in
            if let error = error {
                self.delegate?.didFailToFetchDeviceData(with: error)
            } else {
                APIState.shared.url = url
                APIState.shared.token = token
                print("HomeManager URL: \(url ?? "no url returned")")
                //print("HomeManager Token: \(token ?? "no token returned")")
                self.fetchDeviceData { result in
                    switch result {
                    case .success(let devices):
                        self.delegate?.didReceiveDevices(devices)
                    case .failure(let error):
                        self.delegate?.didFailToFetchDeviceData(with: error)
                    }
                }
            }
        }
    }
    static var shared: HomeManager {
           return AppDelegate.sharedHomeManager
       }
    func fetchDeviceData(completion: @escaping (Result<[HomeAssistantData], Error>) -> Void) {
        let urlString = "\(APIState.shared.url ?? "error: ")states"
       // print(urlString)
        if let cachedData = cache.object(forKey: "devices") {
            self.deviceArray = cachedData as! [HomeAssistantData]
            delegate?.didReceiveDevices(self.deviceArray)
            completion(.success(self.deviceArray))
        } else {
            print("HomeManager call for \(urlString)")
            callForData(urlString: urlString) { result in
                switch result {
                case .success(let devices):
                    self.deviceArray = devices
                    self.cache.setObject(devices as NSArray, forKey: "devices")
                    self.delegate?.didReceiveDevices(devices)
                    completion(.success(devices))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Call this function to remove all objects from the cache when the user logs out
    func clearCache() {
        cache.removeAllObjects()
    }
    
    
    func callForData(urlString: String, completion: @escaping (Result<[HomeAssistantData], Error>) -> Void) {
        let token = APIState.shared.token
        //1: Create a URL
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url:url)
            
            //2: Create a URLSession
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer \(token  ?? "Error")", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //3: Give Session a task
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    print(error)
                    completion(.failure(error))
                    return
                }
                guard let safeData = data else {return}
                do {
                    
                    let device = try JSONDecoder().decode([HomeAssistantData].self, from: safeData)
                    var filteredDevices = [HomeAssistantData]()
                    for item in device {
                        /// sensor is the entity id after the word sensor so it should be contained within the switch entity_id to be added to the array ie sensor.{0x0015bc002f00edf3}_energy
                        //let sensor = AppUtility.selectDeviceFromEntityString(entity: item.entity_id)
                        if item.entity_id.hasSuffix("_energy") || item.entity_id.hasSuffix("_battery_level") || item.entity_id.hasSuffix("_battery_state") || item.entity_id.hasPrefix("switch") {
                            filteredDevices.append(item)
                        }
                    }
                    self.cache.setObject(filteredDevices as NSArray, forKey: "devices")
                    DispatchQueue.main.async { [self] in
                        self.delegate?.didReceiveDevices(filteredDevices)
                    }
                    completion(.success(filteredDevices))
                } catch {
                    print("JSONDecoder error:", error)
                    completion(.failure(error))
                }
            }
            //4: Start the task
            task.resume()
        }
    }
}




