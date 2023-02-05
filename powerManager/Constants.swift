//
//  Constants.swift
//  powerManager
//
//  Created by Paul Olphert on 16/01/2023.
//

struct K {
    static let appName = "⚡️PowerManager"
    static let loginToBatteryMonitor = "LoginToBatteryMonitor"
    static let registerToBatteryMonitor = "RegisterToBatteryMonitor"
    static let settingsToBatteryMonitor = "settingsToBatteryMonitor"
    static let baseURL = "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/"
    static let plugStateUrl = "https://wfebyv7u1xhb8wl7g44evjkl1o7t5554.ui.nabu.casa/api/services/switch/"
    static let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmNzI5MGM3OTE0NjE0ODhmOGYzZjFjMDU4YjA2YmRhOSIsImlhdCI6MTY3Mjc1OTk4MCwiZXhwIjoxOTg4MTE5OTgwfQ.X9E2pp6XUxjORMAK_mJSsZK5GG6rv4b-3c8X88eX1yQ"
    static let cellIdentifier = "ReusableCell"
    static let celNibName = "DevicesCell"
    static let turnOff = "turn_off"
    static let turnOn = "turn_on"
    static let on = "on"
    static let off = "off"
    static let batteryLevel = "battery_level"
    static let switchs = "switch"
    
    struct ColourAssets {
        static let plugIconColourOff = "PlugIconColourOff"
        static let plugIconColourOn = "PlugIconColourOn"
        static let numberColour = "NumberColor"
        static let  affirmAction = "AffirmAction"
    }
    
    struct FStore {
        
        static let homeAssistantCollection = "homeAssistantCollection"
        static let user = "user"
        static let entity_id = "entity_id"
        static let state = "state"
        static let lastUpdated = "lastUpDated"
        static let friendlyName = "friendly_name"
        static let uuid = "uuid"
        static let date = "date"
    }
  
}
