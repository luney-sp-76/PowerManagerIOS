//
//  PlugControl.swift
//  powerManager
//
//  Created by Paul Olphert on 04/01/2023.
//

import Foundation
protocol PlugManagerDelegate {
    func didUpdateDevice(_ plugControl: PlugControl)
    func didFailWithError(error: Error)
}

struct PlugControl {
    
    let homeAssistantPostUrl = "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/services/switch/"
    var delegate: PlugManagerDelegate?
    
    func fetchDeviceData(deviceName: String, urlEndPoint: String) {
        let urlString = "\(homeAssistantPostUrl)\(urlEndPoint)"
        print(urlString)
        sendRequest(urlString: urlString)
    }
    
    func sendRequest(urlString: String) {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmNzI5MGM3OTE0NjE0ODhmOGYzZjFjMDU4YjA2YmRhOSIsImlhdCI6MTY3Mjc1OTk4MCwiZXhwIjoxOTg4MTE5OTgwfQ.X9E2pp6XUxjORMAK_mJSsZK5GG6rv4b-3c8X88eX1yQ"
        
        print("POST task 1")
        //1: Create a URL
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url:url)
            //2: Prepare JSON data
            let json: [String: Any] = ["entity_id" : "switch.0x0015bc002f00edf3"]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            
            //3: Create POST request
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //4: Insert the JSON into the POST request
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
            }
            
            task.resume()
        }
    }
}
