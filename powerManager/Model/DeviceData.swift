//
//  DeviceData.swift
//  powerManager
//
//  Created by Paul Olphert on 02/01/2023.
//


import Foundation

struct DeviceData: Decodable {
    
    
    var entity_id: String
    var state: String
    var attributes: Attributes
    var last_changed: String
    var last_updated: String
    var context: Context
  
}

struct Attributes: Decodable {
    var friendlyName: String

    
    
    private enum CodingKeys: String, CodingKey {
        case friendlyName = "friendly_name"
       
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let friendlyName = try container.decode(String.self, forKey: .friendlyName)
      
        self.friendlyName = friendlyName
    }
    
}



struct Context: Decodable {
    var id: String
    var parent_id: String?
    var user_id: String?
}

struct Person: Decodable {
    var person: String?
}

struct Types: Decodable {
    var type: String?
}

struct Location: Decodable {
    var location: [Double]?
}


