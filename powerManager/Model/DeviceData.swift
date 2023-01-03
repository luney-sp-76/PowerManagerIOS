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
    //alternates Level uses unit_of_measurement while State uses Low Power Mode (which needs changed to be underscored)***
    let unit_of_measurement: String
    let Low_Power_Mode: Bool
    //***
    let device_class: String
    let icon: String
    let friendly_name: String
    }

struct Context: Decodable {
        let id: String
        let parent_id: String
        let user_id: String
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
