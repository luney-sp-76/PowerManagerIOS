//
//  DataProvider.swift
//  powerManager
//
//  Created by Paul Olphert on 05/02/2023.
//

import Foundation
// creates a delegate and calls the delegate function that calls the homeassistant api for all devices
//that will return the data to the Firebase Updater struct
class DataProvider {
    let homeManager = HomeManager()
    let firebaseUpdater = FirebaseUpdater()

    func transferData() {
        homeManager.delegate = firebaseUpdater
        homeManager.fetchDeviceData()
    }
}
