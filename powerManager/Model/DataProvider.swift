//
//  DataProvider.swift
//  powerManager
//
//  Created by Paul Olphert on 05/02/2023.
//

import Foundation

class DataProvider {
    let homeManager = HomeManager()
    let firebaseUpdater = FirebaseUpdater()

    func transferData() {
        homeManager.delegate = firebaseUpdater
        homeManager.fetchDeviceData()
    }
}
