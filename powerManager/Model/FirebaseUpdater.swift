//
//  FirebaseUpdater.swift
//  powerManager
//
//  Created by Paul Olphert on 05/02/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// the FirebaseUpdater class implements the HomeManagerDelegate protocol and implements the didReceiveDevices(_:) method.
class FirebaseUpdater: HomeManagerDelegate {
    let db = Firestore.firestore()
    
    func didReceiveDevices(_ devices: [HomeAssistantData]) {
        if let userData = Auth.auth().currentUser?.email {
            updateFirebase(with: devices, userData: userData)
        }
       
    }
    
    func updateFirebase(with devices: [HomeAssistantData], userData: String) {
        for device in devices {
            DispatchQueue.main.async {
                self.db.collection(K.FStore.homeAssistantCollection).addDocument(data: [K.FStore.user: userData, K.FStore.entity_id: device.entity_id, K.FStore.state: device.state, K.FStore.lastUpdated: device.last_updated, K.FStore.friendlyName: device.attributes.friendlyName, K.FStore.uuid: device.context.id]) {
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
