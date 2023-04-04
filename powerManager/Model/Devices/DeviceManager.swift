//
//  DeviceManager.swift
//  powerManager
//
//  Created by Paul Olphert on 01/01/2023.


import Foundation
import FirebaseAuth

/**
 A protocol for objects that manage any devices.

 Objects conforming to this protocol can be notified of updates to  devices, and can handle errors that occur while managing devices.
 */
protocol DeviceManagerDelegate {
    /**
        Notifies the delegate that a device update has occurred.

        - Parameters:
           - deviceManager: The `DeviceManager` object that initiated the update.
           - device: The `DeviceModel` object that initiated the update
        */
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel)
    
    /**
       Notifies the delegate that an error has occurred while managing a device.

       - Parameters:
          - error: The error that occurred.
       */
    func didFailWithError(error: Error)
}


var plugControl = PlugControl()
var homeAssistantFetchUrl: String?
var token: String?

/**
This struct manages the fetching of device data and battery level management. It conforms to the DeviceManagerDelegate protocol and contains functions to fetch device data, fetch the state of a plug device, make a network call, parse JSON data, and manage the battery level of a device. The manageBattery function is a mutating function that takes in a device, its lowest battery charge level, current battery level, and the name of the plug device to control. It returns a string indicating whether the device should be turned on or off.
*/
struct DeviceManager  {
    
    var homeAssistantFetchUrl: String?
    var token: String?
    var isOff = true
    let dataProvider = DataProvider()
    var delegate: DeviceManagerDelegate?
    
    
    /**
     Fetches device data for a given device.

     - Parameters:
        - deviceName: The name of the device to fetch data for.
     */
    func fetchDeviceData(deviceName: String) {
        let urlString = "\(APIState.shared.url ?? "Error")states/\(deviceName)"
        //print(urlString)
        callForData(urlString: urlString)
    }
    /**
     Fetches the state of a plug device.

     - Parameters:
        - urlEndPoint: The endpoint for the plug device to fetch the state of.
     */
    func fetchPlugState(urlEndPoint: String){
        let urlString = "\(APIState.shared.url ?? "Error")states/\(urlEndPoint)"
        callForData(urlString: urlString)
    }
    
    
    /**
     Calls for data from a given URL.

     - Parameters:
        - urlString: The URL to call for data.
     */
    func callForData(urlString: String) {
        let token = APIState.shared.token
        
        //Create a URL
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url:url)
            
       
            //Create a URLSession
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer \(token ?? "Error")", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
       
            //Give Session a task
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                guard let safeData = data else {return}
                
                // use the Device classes switch and sensor to determine the type of device being handled
                if let device = self.parseJSON(safeData) {
                    self.delegate?.didUpdateDevice(self, device: device)
                }
            }
            
            // Start the task
            task.resume()
        }
        
    }
    
    /**
     
      function parses the Data from the HomeAssistant Device response
     - Parameters:
        - Data from device endpoint in the JSON format
     - Returns:
        - optional DeviceModel
     */
    func parseJSON(_ deviceData: Data) -> DeviceModel? {
        
        let decoder = JSONDecoder()
        do {
            
            let decodedData = try decoder.decode(DeviceData.self, from: deviceData)
            let id = decodedData.entity_id
            let state = decodedData.state
            let name = decodedData.attributes.friendlyName
            let lastUpdate = decodedData.last_updated
            let uuid = decodedData.context.id
       
            let device = DeviceModel(id: id, state: state, name: name, lastUpdate: lastUpdate, uuid: uuid)
            return device
            
        } catch {
            self.delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
    
    
    /**
     A mutating function that manages the battery level of a device.

     - Parameters:
        - device: The device to manage.
        - lowestBatteryChargeLevel: The lowest battery level at which the device should be turned on.
        - currentBatteryLevel: The current battery level of the device.
        - plugName: The name of the plug device to control.

     - Returns: A string indicating whether the device should be turned on or off.
     */
    mutating func manageBattery(device: DeviceModel, lowestBatteryChargeLevel: Int, currentBatteryLevel: Int, plugName: String)-> String {
        
        var returnString = K.on
        if currentBatteryLevel == 100 && device.id == plugName && device.state == K.on {
            //attempting post request
            print("attempting to send a post request....")
            plugControl.fetchPlugData(urlEndPoint: K.turnOff, device: plugName)
            //update firebase
            dataProvider.transferData { result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print("error sending device data \(error)")
                }
            }
            isOff = true
            print("is OFF Now? \(isOff)")
            returnString = K.off
            
        } else if currentBatteryLevel <= lowestBatteryChargeLevel && device.id == plugName && device.state == K.off {
            print("attempting to send a post request....")
            plugControl.fetchPlugData(urlEndPoint: K.turnOn, device: plugName)
            dataProvider.transferData { result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print("error sending device data \(error)")
                }
            }
            isOff = false
            print("is OFF Now? \(isOff)")
            returnString = K.on
        }
        return returnString
        
    }
    
    
}




