//
//  HomeAssistantData.swift
//  powerManager
//
//  Created by Paul Olphert on 17/01/2023.
//

import Foundation

struct HomeAssistantData: Decodable {
    let entity_id: String
    let state: String
    let attributes: Attributes
    let last_changed: String
    let last_updated: String
    let context: Context
    
    // Add this initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entity_id = try container.decode(String.self, forKey: .entity_id)
        state = try container.decode(String.self, forKey: .state)
        attributes = try container.decode(Attributes.self, forKey: .attributes)
        last_updated = try container.decode(String.self, forKey: .last_updated)
        last_changed = try container.decode(String.self, forKey: .last_changed)
        context = try container.decode(Context.self, forKey: .context)
    }
    // Add this enum
    private enum CodingKeys: String, CodingKey {
        case entity_id = "entity_id"
        case state = "state"
        case attributes = "attributes"
        case last_changed = "last_changed"
        case last_updated = "last_updated"
        case context = "context"
    }
    struct Attributes: Decodable {
        var unitOfMeasurement: String?
        var name: String?
        var lowPowerMode: Bool?
        var attributesId: String?
        var deviceClass: String?
        var icon: String?
        var friendlyName: String
        var supportedFeatures: Int?
        var userId: String?
        
        //MARK: - codingKey enum
        public enum CodingKeys: String, CodingKey {
            case unitOfMeasurement = "unit_of_measurement"
            case name = "Name"
            case lowPowerMode = "Low Power Mode"
            case attributesId = "id"
            case deviceClass = "device_class"
            case icon
            case friendlyName = "friendly_name"
            case userId = "user_id"
        }
        //MARK: - decoder
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let unitOfMeasurement = try container.decodeIfPresent(String.self, forKey: .unitOfMeasurement)
            let lowPowerMode = try container.decodeIfPresent(Bool.self, forKey: .lowPowerMode)
            let attributesId = try container.decodeIfPresent(String.self, forKey: .attributesId)
            let deviceClass = try container.decodeIfPresent(String.self, forKey: .deviceClass)
            let icon = try container.decodeIfPresent(String.self, forKey: .icon)
            let friendlyName = try container.decode(String.self, forKey: .friendlyName)
            let userId = try container.decodeIfPresent(String.self, forKey: .userId)
            //MARK: - trimming white space to return data
            self.unitOfMeasurement = unitOfMeasurement
            self.lowPowerMode = lowPowerMode
            self.attributesId = attributesId
            self.deviceClass = deviceClass
            self.icon = icon
            self.friendlyName = friendlyName
            self.userId = userId
        }
    }
    struct Context: Decodable {
        let id: String
        let parent_id: Any?
        let user_id: Any?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case parent_id
            case user_id
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
            self.parent_id = try container.decodeIfPresent(String.self, forKey: .parent_id) ?? nil
            self.user_id = try container.decodeIfPresent(String.self, forKey: .user_id) ?? nil
        }
    }
}
