//
//  EnergyModel.swift
//  powerManager
//
//  Created by Paul Olphert on 16/02/2023.
//

/// Model for energy usage data
class EnergyModel {
    /// Overall energy usage value
    var overall: Double
    
    /// Unix timestamp for energy usage data
    var unixTimestamp: Double
    
    /// Timestamp for energy usage data in string format
    var timestamp: String
    
    /**
     
     Initializer for EnergyModel class
      - Parameters:
       - overall: Overall energy usage value
       - unixTimestamp: Unix timestamp for energy usage data
       - timestamp: Timestamp for energy usage data in string format
     
     */
    init(overall: Double, unixTimestamp: Double, timestamp: String) {
        self.overall = overall
        self.unixTimestamp = unixTimestamp
        self.timestamp = timestamp
    }
}

extension EnergyModel: Equatable {
    /**
     
     Check if two EnergyModel objects are equal
        - Parameters:
         - lhs: First EnergyModel object
         - rhs: Second EnergyModel object
     
        - Returns: True if the two EnergyModel objects have equal overall, unixTimestamp and timestamp values, false otherwise
     
     */
    static func == (lhs: EnergyModel, rhs: EnergyModel) -> Bool {
        return lhs.overall == rhs.overall &&
        lhs.unixTimestamp == rhs.unixTimestamp &&
        lhs.timestamp == rhs.timestamp
    }
}
