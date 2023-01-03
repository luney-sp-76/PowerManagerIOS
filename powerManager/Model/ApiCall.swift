//
//  ApiCall.swift
//  powerManager
//
//  Created by Paul Olphert on 03/01/2023.
//

import Foundation

class ApiCall {
    
    func callForData(urlString: String) -> DeviceModel {
        let token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmNzI5MGM3OTE0NjE0ODhmOGYzZjFjMDU4YjA2YmRhOSIsImlhdCI6MTY3Mjc1OTk4MCwiZXhwIjoxOTg4MTE5OTgwfQ.X9E2pp6XUxjORMAK_mJSsZK5GG6rv4b-3c8X88eX1yQ"
        
        var device = DeviceModel(id:"none",state:"none",name:"none")
        print("is this working?")
        //1: Create a URL
        if let url = URL(string: urlString){
            var urlRequest = URLRequest(url:url)
            urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "GET"
            
            //2: Create a URLSession
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            print("task 3")
            //3: Give Session a task
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                guard error == nil else {
                    print("error calling GET on /todos/1")
                    print(error!)
                    return
                }
                guard let safeData = data
                else {
                    print("error: did not receive data")
                    return
                }
                
                do {
                    //decode all the data requied for the app to read battery level charging state
                    let decodedData = try JSONDecoder().decode(DeviceData.self, from:safeData)
                    
                    let id = decodedData.entity_id
                    let state = decodedData.state
                    let name = decodedData.attributes[0].friendly_name
                    
                    device = DeviceModel(id: id, state: state, name: name)
                    
                    
                } catch {
                    print(error)
                    return
                }
                
                
                
            }
            //4: Start the task
            task.resume()
        }
        return device
    }
    
}

 

