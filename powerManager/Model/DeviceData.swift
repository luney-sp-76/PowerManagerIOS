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
    let attributes: Attributes
    let last_changed: String
    let last_updated: String
    let context: Context
    
}

struct Attributes: Decodable {
    //alternates Level uses unit_of_measurement while State uses Low Power Mode (which needs changed to be underscored)***
    let unit_of_measurement: String?
    let Available: String?
    let Name: String?
    let Country: String?
    let Total: String?
    let Types: Types?
    let Locality: String?
    let Location: [Location]?
    let Ocean: String?
    //**Will be problematic as the have spaces and brackets
    let Available_Important: String?
    let Available_Opportunistic: String?
    let Low_Power_Mode: Bool?
    let Allows_VoIP: Bool?
    let Carrier_ID: String?
    let Carrier_Name: String?
    let ISO_Country_Code: String?
    let Mobile_Country_Code: String?
    let Mobile_Network_Code: String?
    let Hardware_Address: String?
    let Administrative_Area: String?
    let Areas_Of_Interest: String?
    let Inland_Water: String?
    let iSO_Country_Code: String?
    
    
    //**
    let id: String?
    let Confidence: String?
    let auto_update: Bool?
    let installed_version: String?
    let latest_version: String?
    let release_summary: String?
    let in_progress: Bool?
    let release_url: String?
    let skipped_version: String?
    let title: String?
    let entity_picture: String?
    let next_dawn: String?
    let next_dusk: String?
    let next_midnight: String?
    let next_noon: String?
    let next_rising: String?
    let next_setting: String?
    let elevation: Double?
    let azimuth: Double?
    let rising: Bool?
    let radius:Int?
    let passive: Bool?
    let persons: Person?
    let device_class: String?
    let editable: Bool?
    let icon: String?
    let latitude: Double?
    let longitude: Double?
    let gps_accuracy: Double?
    let source: String?
    let source_type: String?
    let friendly_name: String
    let supported_features: String?
    let user_id: String?
}



struct Context: Decodable {
    let id: String
    let parent_id: String?
    let user_id: String?
}

struct Person: Decodable {
    
}

struct Types: Decodable {
    let type: String?
}

struct Location: Decodable {
    let location: [Double]?
}

//Battery Level
//{"entity_id":"sensor.iphone_8_number_1_battery_level","state":"100","attributes":{"unit_of_measurement":"%","device_class":"battery","icon":"mdi:battery","friendly_name":"iPhone 8 Number 1 Battery Level"},"last_changed":"2023-01-01T23:56:03.420213+00:00","last_updated":"2023-01-01T23:56:03.420213+00:00","context":{"id":"01GNQW71YWRQT4HMGDDS7ECP4K","parent_id":null,"user_id":null}}%
//Battery State
//{"entity_id":"sensor.iphone_8_number_1_battery_state","state":"Full","attributes":{"Low Power Mode":false,"icon":"mdi:battery","friendly_name":"iPhone 8 Number 1 Battery State"},"last_changed":"2023-01-01T23:56:03.421246+00:00","last_updated":"2023-01-01T23:56:03.421246+00:00","context":{"id":"01GNQW71YXYJQKDNQX8H8B8XQB","parent_id":null,"user_id":null}}%
//cURL Cloud
//curl -X GET -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmNzI5MGM3OTE0NjE0ODhmOGYzZjFjMDU4YjA2YmRhOSIsImlhdCI6MTY3Mjc1OTk4MCwiZXhwIjoxOTg4MTE5OTgwfQ.X9E2pp6XUxjORMAK_mJSsZK5GG6rv4b-3c8X88eX1yQ" \
//-H "Content-Type: application/json" \
//https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/states/sensor.iphone_8_number_1_battery_level
////cURL local
//curl -X GET -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmNzI5MGM3OTE0NjE0ODhmOGYzZjFjMDU4YjA2YmRhOSIsImlhdCI6MTY3Mjc1OTk4MCwiZXhwIjoxOTg4MTE5OTgwfQ.X9E2pp6XUxjORMAK_mJSsZK5GG6rv4b-3c8X88eX1yQ" \
//-H "Content-Type: application/json" \
//http://homeassistant.local:8123/api/states/sensor.iphone_8_number_1_battery_state
//
