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
    var deviceInfo: [HomeAssistantData] = []
    var deviceData: [HomeData] = []
    var entity: String =  ""
    var state: String = ""
    var lastUpdated: String = ""
    var friendlyName: String = ""
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeManager.delegate = self
        homeManager.fetchDeviceData()
        sendData()
        loadData()
        
    }
    
    
    func sendData(){
        if let userData = Auth.auth().currentUser?.email
        {for devices in self.deviceInfo {
            if devices.entity_id.contains("battery_level") || devices.entity_id.contains("switch"){
                self.entity = devices.entity_id
                self.state = String(devices.state)
                self.lastUpdated = devices.last_updated
                self.friendlyName = devices.attributes.friendlyName
            }
        }
            db.collection(K.FStore.homeAssistantCollection).addDocument(data: [K.FStore.user: userData, K.FStore.entity_id: entity, K.FStore.state: state, K.FStore.lastUpdated: lastUpdated, K.FStore.friendlyName: friendlyName]) {
                error in
                if let e = error {
                    print("there was an issue sending data to FireStore \(e)")
                } else {
                    print("Successfully saved data")
                }
            }
        }
    }
    
    
    func loadData() {
        // reset the device data to none
        deviceData = []
        db.collection(K.FStore.homeAssistantCollection).getDocuments { querySnapshot, error in
            if let e = error {
                print("There was an issue retrieving data from the firestore \(e)")
            } else {
                if let snapShotDocuments = querySnapshot?.documents {
                    for doc in snapShotDocuments {
                        print(doc.data())
                    }
                }
            }
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
                
            }
        }
    }
    
    
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
