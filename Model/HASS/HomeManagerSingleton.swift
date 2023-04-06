//
//  HomeManagerSingleton.swift
//  powerManager
//
//  Created by Paul Olphert on 27/02/2023.
//

import Foundation
//a singleton pattern to ensure that there is only one instance of HomeManager throughout the app. This way, when BatteryMonitorViewController sets itself as the delegate, it will not interfere with the delegate set by SettingsViewController.
class HomeManagerSingleton {
    static let shared = HomeManagerSingleton()
    private let homeManager: HomeManager
    
    private init() {
        homeManager = HomeManager()
    }
    
    func fetchDeviceData(completion: @escaping (Result<[HomeAssistantData], Error>) -> Void) {
        homeManager.fetchDeviceData(completion: completion)
    }
    
    func setDelegate(_ delegate: HomeManagerDelegate) {
        homeManager.delegate = delegate
    }
}
