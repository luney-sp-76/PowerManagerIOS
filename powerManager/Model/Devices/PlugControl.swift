//
//  PlugControl.swift
//  powerManager
//
//  Created by Paul Olphert on 04/01/2023.
//

import Foundation
import FirebaseAuth
/**
 A protocol for objects that manage plug devices.

 Objects conforming to this protocol can be notified of updates to plug devices, and can handle errors that occur while managing plug devices.
 */
protocol PlugManagerDelegate {
    /**
        Notifies the delegate that a device update has occurred.

        - Parameters:
           - plugControl: The `PlugControl` object that initiated the update.
        */
    func didUpdateDevice(_ plugControl: PlugControl)
    /**
       Notifies the delegate that an error has occurred while managing a device.

       - Parameters:
          - error: The error that occurred.
       */
    func didFailWithError(error: Error)
}
/**
 A struct that manages plug devices.

 This struct includes functions to fetch data for a given plug device and send POST requests to turn the device on or off.
 */
struct PlugControl {
    
   // let homeAssistantPostUrl = K.baseURL
    var delegate: PlugManagerDelegate?
    var homeAssistantPostUrl: String?

    /**
        Fetches data for a given plug device.

        - Parameters:
           - urlEndPoint: The endpoint for the plug device to fetch data for.
           - device: The name of the plug device to fetch data for.
        */
    func fetchPlugData(urlEndPoint: String, device: String) {
        let urlString = "\(APIState.shared.url ?? "Error")services/switch/\(urlEndPoint)"
        print(urlString)
        sendRequest(urlString: urlString, device: device)
    }
    
    /**
        Sends a POST request to turn a plug device on or off.

        - Parameters:
           - urlString: The URL to send the POST request to.
           - device: The name of the plug device to turn on or off.
        */
    func sendRequest(urlString: String, device: String) {
        let token = APIState.shared.token
        let plug = device
  
        // Create a URL
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url:url)
      
            // Prepare JSON data
            let json: [String: Any] = ["entity_id" : "\(plug)"]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
         
            // Create POST request
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(token ?? "Error")", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
            // Insert the JSON into the POST request
            urlRequest.httpBody = jsonData
     
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
              
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    self.delegate?.didUpdateDevice(self)
                    print(responseJSON)
                    
                }
                
                self.delegate?.didUpdateDevice(self)
            }
            
            task.resume()
        }
    }
}
