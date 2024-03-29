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
    
    let homeAssistantPostUrl = K.baseURL
    var delegate: PlugManagerDelegate?
    
    func fetchPlugData(urlEndPoint: String, device: String) {
        let urlString = "\(homeAssistantPostUrl)services/switch/\(urlEndPoint)"
        print(urlString)
        sendRequest(urlString: urlString, device: device)
    }
    
    func sendRequest(urlString: String, device: String) {
        let token = K.token
        let plug = device
        //print("POST task 1 started...")
        //1: Create a URL
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url:url)
           // print("POST task 1 complete")
           // print("POST task 2 started...")
            //2: Prepare JSON data
            let json: [String: Any] = ["entity_id" : "\(plug)"]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
           //print("POST task 2 complete")
            //print("POST task 3 started...")
            //3: Create POST request
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
           // print("POST task 3 complete")
           // print("POST task 4 started...")
            //4: Insert the JSON into the POST request
            urlRequest.httpBody = jsonData
            //print("POST task 4 complete")
            //print("POST task 5 started...")
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                //print("POST task 5 complete")
                //print("POST task 6 started...")
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    self.delegate?.didUpdateDevice(self)
                    print(responseJSON)
                    
                }
                //print("POST task 6 complete")
                self.delegate?.didUpdateDevice(self)
            }
            
            task.resume()
        }
    }
}
