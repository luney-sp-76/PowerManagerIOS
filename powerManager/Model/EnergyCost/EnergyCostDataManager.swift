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
        //The combineEnergyData function takes in an array of EnergyModel objects and an array of HomeData objects, and filters the HomeData objects to only include those with entity IDs ending in "_energy". It then creates an empty array of ChartDataEntry objects, sets up a DateFormatter, and loops through the filtered HomeData objects.
        
//        For each HomeData object, the function finds the EnergyModel object with the closest timestamp to the HomeData object's lastUpdated timestamp. It calculates the cost of energy for this reading, and creates a new ChartDataEntry object with the timestamp converted to Unix time and the cost as the y-value. The function then appends the new ChartDataEntry object to the array.
//
//        Finally, the function returns the array of ChartDataEntry objects.
        func combineEnergyData(energyModels: [EnergyModel], energyReadings: [HomeData], chartView: LineChartView, dateValueFormat: DateValueFormatter) -> (chartDataEntries: [ChartDataEntry], totalCost: Double) {
            // Initialize total cost to zero
            var totalCost: Double = 0.0
            
            // Filter energyReadings to only include data from devices with entity IDs ending in "_energy"
            let filteredReadings = energyReadings.filter { $0.entity_id.hasSuffix("_energy") }
            print(energyModels[0].timestamp)
            print(energyReadings[0].lastUpdated)

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
                    totalCost += cost // Add cost to total
                    let chartDataEntry = ChartDataEntry(x: (dateFormatter.date(from: energyReading.lastUpdated)?.timeIntervalSince1970 ?? 0), y: cost)
                    chartDataEntries.append(chartDataEntry)
                }
            }

            let xAxis = chartView.xAxis
            xAxis.valueFormatter = dateValueFormat

            // Set the date range on the x-axis
            let minTimestamp = chartDataEntries.min(by: { $0.x < $1.x })?.x ?? 0
            let maxTimestamp = chartDataEntries.max(by: { $0.x < $1.x })?.x ?? 0
            xAxis.axisMinimum = minTimestamp
            xAxis.axisMaximum = maxTimestamp

            return (chartDataEntries, totalCost)
        }


    }


