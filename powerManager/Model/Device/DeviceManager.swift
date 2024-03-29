//
//  DeviceManager.swift
//  powerManager
//
//  Created by Paul Olphert on 01/01/2023.
// TODO / Refactor to allow the callForData function to be used for the plug and the phone

import Foundation

protocol DeviceManagerDelegate {
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel)
    func didFailWithError(error: Error)
}
var plugControl = PlugControl()
//var currentBatteryLevel = 21
struct DeviceManager  {
    var isOff = true
    let dataProvider = DataProvider()
    let homeAssistantFetchUrl = K.baseURL
    var delegate: DeviceManagerDelegate?
    //call to return the iphone BatteryLevel state (should be an int) used UrlEndPoint Model to form the endpoints

    // returns a DeviceModel from the ApiCall Model
    func fetchDeviceData(deviceName: String) {
        let urlString = "\(homeAssistantFetchUrl)states/\(deviceName)"
        print(urlString)
        callForData(urlString: urlString)
    }
    //for testing use switch.0x0015bc002f00edf3 as the urlEndPoint
    func fetchPlugState(urlEndPoint: String){
        let urlString = "\(homeAssistantFetchUrl)states/\(urlEndPoint)"
        callForData(urlString: urlString)
    }
    
    
    
    func callForData(urlString: String) {
        let token = K.token
        
     
        //print("\(urlString)task 1")
        //1: Create a URL
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url:url)
            
            //print("task 2")
            //2: Create a URLSession
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
           //print("task 3 in Device Manager")
            //3: Give Session a task
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
//            print("device name: \(id)")
//            print("friendly name: \(name)")
//            print("Unique device ID: \(uuid)")
//            print("current state:\(state)")
//            print("last updated: \(lastUpdate)")
//            print("")
       
            
            let device = DeviceModel(id: id, state: state, name: name, lastUpdate: lastUpdate, uuid: uuid)
            return device
            
        } catch {
            self.delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
    
   
    
    mutating func manageBattery(device: DeviceModel, lowestBatteryChargeLevel: Int, currentBatteryLevel: Int, plugName: String)-> String {
        var returnString = K.on
        print("The request from batteryMonitor is recieved..")
        print("Current Battery Level \(currentBatteryLevel) which is of type...")
        print(type(of: currentBatteryLevel))
        print("device is the plug \(device.id == plugName)")
        print("lowest Charge level \(lowestBatteryChargeLevel)")
        print("The plug is On:  \(device.state == K.on)")
        print("The plug state is: \(device.state)")
        print("The plug Boolean is Off:  \(isOff == false)")
        
        
        if currentBatteryLevel == 100 && device.id == plugName && device.state == K.on {
            //attempting post request
            print("attempting to send a post request....")
            plugControl.fetchPlugData(urlEndPoint: K.turnOff, device: plugName)
            //update firebase
            dataProvider.transferData()
            isOff = true
            print("is OFF Now? \(isOff)")
            returnString = K.off

        } else if currentBatteryLevel <= lowestBatteryChargeLevel && device.id == plugName && device.state == K.off {
            print("attempting to send a post request....")
            plugControl.fetchPlugData(urlEndPoint: K.turnOn, device: plugName)
            dataProvider.transferData()
            isOff = false
            print("is OFF Now? \(isOff)")
            returnString = K.on
        }
        return returnString
        
    }
    
    
}




