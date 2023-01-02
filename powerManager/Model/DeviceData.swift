//
//  DeviceData.swift
//  powerManager
//
//  Created by Paul Olphert on 02/01/2023.
//


import Foundation

struct DeviceData: Decodable {
    let entity_id: String
    let state: String
    let attributes: [Attributes]
    let last_changed: String
    let last_updated: String
    let context: [Context]
    
    }

struct Attributes: Decodable {
        let friendly_name: String
        let Low_Power_Mode: Bool
    }

struct Context: Decodable {
        let id: String
        let parent_id: String
        let user_id: String
}
