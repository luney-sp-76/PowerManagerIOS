//
//  StatisticsViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 15/01/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class StatisticsViewController: UIViewController {
    
    var homeManager = HomeManager()
    // the devices from HomeAssistant go here
    var deviceInfo: [HomeAssistantData] = []
    //the data for the database goes in here
    var deviceData: [HomeData] = []
    var entity: String =  ""
    var state: String? = ""
    var lastUpdated: String = ""
    var friendlyName: String = ""
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set this view as a homeManagerDelegate
        homeManager.delegate = self
        //collect all the data
        homeManager.fetchDeviceData()
    }
    
    // send the data to firebase from the deviceInfo array
    func sendData(){
        if let userData = Auth.auth().currentUser?.email{
            uploadData(userData: userData)
        }
        //pull data back from the database
        loadData()
      
        print("of \(deviceInfo.count) devices")
    }
    
    
    func loadData() {
        // reset the device data to none
        deviceData = []
        DispatchQueue.main.async{
            self.db.collection(K.FStore.homeAssistantCollection).getDocuments { querySnapshot, error in
                if let e = error {
                    print("There was an issue retrieving data from the firestore \(e)")
                } else {
                    if let snapShotDocuments = querySnapshot?.documents {
                        for doc in snapShotDocuments {
                            let data = doc.data()
                            if let userData = data[K.FStore.user]
                                as? String, let entity = data[K.FStore.entity_id], let state = data[K.FStore.state], let lastUpdated = data[K.FStore.lastUpdated], let friendlyName = data[K.FStore.friendlyName] {
                                let newDevice = HomeData(user: userData, entity_id: entity as! String, state:state as! String, lastUpdated: lastUpdated as! String , friendlyName: friendlyName as! String)
                                self.deviceData.append(newDevice)
                            }
                        }
                        print("The database should have \(self.deviceData.count)")
                        self.printData()
                    }
                }
            }
        }
       
    }
    
    func uploadData(userData: String) {
        for devices in deviceInfo {
            
            //}
            DispatchQueue.main.async {
                self.db.collection(K.FStore.homeAssistantCollection).addDocument(data: [K.FStore.user: userData, K.FStore.entity_id: devices.entity_id, K.FStore.state: devices.state, K.FStore.lastUpdated: devices.last_updated, K.FStore.friendlyName: devices.attributes.friendlyName]) {
                    error in
                    if let e = error {
                        print("there was an issue sending data to FireStore \(e)")
                    } else {
                        print("Successfully saved data")
                    }
                }
            }
        }
    }
    
  func  printData() {
      for devices in deviceData {
          print("in the array pulled from the firebase db is \(devices.friendlyName)")
      }
    }
    
    
}
//MARK: - HomeManagerDelegate
// manage the data from the HomeManager and create the data for deviceInfo from the array of Devices
extension StatisticsViewController: HomeManagerDelegate {
    
    func didReceiveDevices(_ devices: [HomeAssistantData]) {
        DispatchQueue.main.async {[self] in
            if !devices.isEmpty {
                self.deviceInfo = devices
                //upload the data to firebase
                sendData()
              
            }
        }
    }
    
    
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
