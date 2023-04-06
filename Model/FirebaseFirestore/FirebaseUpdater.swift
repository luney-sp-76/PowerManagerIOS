//
//  FirebaseUpdater.swift
//  powerManager
//
//  Created by Paul Olphert on 05/02/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/**
 A class that implements the HomeManagerDelegate protocol to update Firebase Firestore with information about home automation devices.
 */
class FirebaseUpdater: HomeManagerDelegate {
    
    /**
        Called when there is an error fetching device data.
        
        - Parameters:
           - error: The error that occurred.
        */
    func didFailToFetchDeviceData(with error: Error) {
        print("Failed to fetch device data: \(error.localizedDescription)")
    }
    
    let db = Firestore.firestore()
   
    /**
       Called when new devices are received from HomeManager.
       
       - Parameters:
          - devices: An array of HomeAssistantData objects representing the new devices.
       */
    func didReceiveDevices(_ devices: [HomeAssistantData]) {
        if let userData = Auth.auth().currentUser?.email {
            updateFirebase(with: devices, userData: userData)
        }
       
    }
    
    /**
     Updates Firebase Firestore with information about the given devices.
     
     - Parameters:
        - devices: An array of HomeAssistantData objects representing the devices to update.
        - userData: The email address of the user associated with the devices.
     */
    func updateFirebase(with devices: [HomeAssistantData], userData: String) {
        let id = Auth.auth().currentUser?.email
        for device in devices {
            DispatchQueue.main.async {
                self.db.collection(K.FStore.homeAssistantDeviceCollection).document(id!).collection(K.FStore.devices).addDocument(data: [K.FStore.user: userData, K.FStore.entity_id: device.entity_id, K.FStore.state: device.state, K.FStore.lastUpdated: device.last_updated, K.FStore.friendlyName: device.attributes.friendlyName, K.FStore.uuid: device.context.id]) {
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
}
