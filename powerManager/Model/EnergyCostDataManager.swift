//
//  EnergyCostDataManager.swift
//  powerManager
//
//  Created by Paul Olphert on 17/02/2023.
//

import Foundation
import Charts
//combine the homedata and energy cost data to create a chart of cost over time
    struct EnergyCostDataManager {
        func combineEnergyData(energyModels: [EnergyModel], energyReadings: [HomeData]) -> [ChartDataEntry] {
            // Filter energyReadings to only include data from devices with entity IDs ending in "_energy"
            let filteredReadings = energyReadings.filter { $0.entity_id.hasSuffix("_energy") }
            //chartData array 
            var chartDataEntries: [ChartDataEntry] = []
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
            for energyReading in filteredReadings {
                // Find the energy model with the closest timestamp to the energy reading timestamp
                var closestEnergyModel: EnergyModel?
                var smallestTimeDiff: Double = Double.greatestFiniteMagnitude
                for energyModel in energyModels {
                    let timeDiff = abs(energyModel.unixTimestamp - (dateFormatter.date(from: energyReading.lastUpdated)?.timeIntervalSince1970 ?? 0))
                    if timeDiff < smallestTimeDiff {
                        smallestTimeDiff = timeDiff
                        closestEnergyModel = energyModel
                    }
                }
                
                // Calculate the cost of energy for this reading
                if let closestEnergyModel = closestEnergyModel {
                    let cost = closestEnergyModel.overall * (Double(energyReading.state) ?? 0.0)
                    let chartDataEntry = ChartDataEntry(x: (dateFormatter.date(from: energyReading.lastUpdated)?.timeIntervalSince1970 ?? 0), y: cost)
                    chartDataEntries.append(chartDataEntry)
                }
            }
            
            return chartDataEntries
        }
    }


