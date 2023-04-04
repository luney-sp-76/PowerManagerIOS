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
    
    /**
     Combines energy data from different sources and calculates the total energy cost within a specified date range.
     
     - Parameters:
     
        - energyModels: An array of EnergyModel objects, representing the energy pricing models.
        - homeData: An array of HomeData objects, representing the home energy data.
        - chartView: A LineChartView object, representing the chart view where the data will be displayed.
        - dateValueFormat: A DateValueFormatter object, used to format the X-axis of the chart view.
        - startDate: A Date object, representing the start date of the range to be considered for energy cost calculation.
        - endDate: A Date object, representing the end date of the range to be considered for energy cost calculation.
     
     - Returns:
        - a tuple with the following properties:
            - chartDataEntries: An array of ChartDataEntry objects, representing the data points to be plotted on the chart.
            - totalCost: A Double value, representing the total cost of energy consumed within the specified date range.
     
     The function filters the energy readings from the homeData array and computes the energy consumption between each "on" and "off" switch state within the specified date range. For each energy consumption, the function calculates the cost using the closest energy pricing model from the energyModels array. The function then creates a ChartDataEntry object for each cost and appends it to the chartDataEntries array. Finally, the function configures the X-axis of the chartView with the provided dateValueFormat, and returns the chartDataEntries array and the totalCost value.
     */
    func combineEnergyData(energyModels: [EnergyModel], homeData: [HomeData], chartView: LineChartView, dateValueFormat: DateValueFormatter, startDate: Date, endDate: Date) -> (chartDataEntries: [ChartDataEntry], totalCost: Double) {
        let energyReadings = homeData.filter { $0.entity_id.hasSuffix("_energy") }
        let switchStates = filteredSwitchStates(homeData: homeData, startDate: startDate, endDate: endDate)
        
        var chartDataEntries: [ChartDataEntry] = []
        var totalCost: Double = 0.0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        var prevOnSwitchState: HomeData? = nil
        for switchState in switchStates {
            if switchState.state == "on" {
                prevOnSwitchState = switchState
            } else if switchState.state == "off", let prevSwitch = prevOnSwitchState {
                let startTime = dateFormatter.date(from: prevSwitch.lastUpdated)?.timeIntervalSince1970 ?? 0
                let endTime = dateFormatter.date(from: switchState.lastUpdated)?.timeIntervalSince1970 ?? 0
                
                let startEnergyReading = closestEnergyReading(timestamp: startTime, energyReadings: energyReadings)
                let endEnergyReading = closestEnergyReading(timestamp: endTime, energyReadings: energyReadings)
                
                if let startEnergyReading = startEnergyReading, let endEnergyReading = endEnergyReading {
                    let energyUsage = (Double(endEnergyReading.state) ?? 0.0) - (Double(startEnergyReading.state) ?? 0.0)
                    
                    let closestEnergyModel = closestEnergyModel(timestamp: endTime, energyModels: energyModels)
                    
                    if let closestEnergyModel = closestEnergyModel {
                        let cost = energyCost(energyUsage: energyUsage, energyModel: closestEnergyModel)
                        let chartDataEntry = ChartDataEntry(x: endTime, y: cost)
                        chartDataEntries.append(chartDataEntry)
                        totalCost += cost
                    }
                }
                prevOnSwitchState = nil
            }
        }
        
        print("Total cost: \(totalCost)")
        print("Chart data entries count: \(chartDataEntries.count)")
        
        let xAxis = chartView.xAxis
        xAxis.valueFormatter = dateValueFormat
        return (chartDataEntries, totalCost)
    }
    
    /**
    Filters switch states from the homeData array within the specified date range.

    - Parameters:

     - homeData: An array of HomeData objects, representing the home energy data.
     - startDate: A Date object, representing the start date of the range to be considered for filtering switch states.
     -  endDate: A Date object, representing the end date of the range to be considered for filtering switch states.
     
    - Returns:
     -  an array of HomeData objects containing the filtered switch states.

    The function initializes a DateFormatter object with the format "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ". It then filters the homeData array to include only those entries with an entity_id containing the string "switch" and a lastUpdated timestamp within the specified date range. The filtered data is stored in the filteredData array, which is then returned.
    */
    func filteredSwitchStates(homeData: [HomeData], startDate: Date, endDate: Date) -> [HomeData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        let filteredData = homeData.filter { $0.entity_id.contains("switch") && dateFormatter.date(from: $0.lastUpdated)?.timeIntervalSince1970 ?? 0 >= startDate.timeIntervalSince1970 && dateFormatter.date(from: $0.lastUpdated)?.timeIntervalSince1970 ?? 0 <= endDate.timeIntervalSince1970 }
        
        print("Filtered switch states count: \(filteredData.count)")
        return filteredData
    }
    
    /**
    Finds the closest energy reading to the given timestamp from an array of energy readings.

   - Parameters:
     
        - timestamp: A TimeInterval value, representing the target timestamp for which the closest energy reading is to be found.
        - energyReadings: An array of HomeData objects, representing the energy readings.
     
    - Returns:
        - an optional HomeData object containing the closest energy reading to the given timestamp, or nil if no energy reading is found.

    The function initializes a DateFormatter object with the format "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ". It then iterates through the energyReadings array and calculates the absolute time difference between each energy reading's lastUpdated timestamp and the given timestamp. The function keeps track of the smallest time difference found (smallestTimeDiff) and the corresponding energy reading (closestEnergyReading). Finally, the function returns the closestEnergyReading object if found, or nil if no energy reading is found.
    */
    func closestEnergyReading(timestamp: TimeInterval, energyReadings: [HomeData]) -> HomeData? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        
        var closestEnergyReading: HomeData?
        var smallestTimeDiff = Double.greatestFiniteMagnitude
        for energyReading in energyReadings {
            let energyReadingTimestamp = dateFormatter.date(from: energyReading.lastUpdated)?.timeIntervalSince1970 ?? 0
            let timeDiff = abs(energyReadingTimestamp - timestamp)
            if timeDiff < smallestTimeDiff {
                smallestTimeDiff = timeDiff
                closestEnergyReading = energyReading
            }
        }
        
        print("Closest energy reading for timestamp \(timestamp): \(closestEnergyReading?.lastUpdated ?? "Not found")")
        return closestEnergyReading
    }
    
    /**
    Finds the closest energy model to the given timestamp from an array of energy models.

    - Parameters:

     - timestamp: A TimeInterval value, representing the target timestamp for which the closest energy model is to be found.
     - energyModels: An array of EnergyModel objects, representing the energy pricing models.
     
    - Returns:
     - an optional EnergyModel object containing the closest energy model to the given timestamp, or nil if no energy model is found.

    The function initializes a DateFormatter object with the format "HH:mm dd-MM-yyyy". It then iterates through the energyModels array and calculates the absolute time difference between each energy model's timestamp and the given timestamp. The function keeps track of the smallest time difference found (smallestTimeDiff) and the corresponding energy model (closestEnergyModel). Finally, the function returns the closestEnergyModel object if found, or nil if no energy model is found.
    */
    func closestEnergyModel(timestamp: TimeInterval, energyModels: [EnergyModel]) -> EnergyModel? {
        var closestEnergyModel: EnergyModel?
        var smallestTimeDiff = Double.greatestFiniteMagnitude
        for energyModel in energyModels {
            let energyModelDateFormatter = DateFormatter()
            energyModelDateFormatter.dateFormat = "HH:mm dd-MM-yyyy"
            let energyModelDate = energyModelDateFormatter.date(from: energyModel.timestamp) ?? Date.distantPast
            let timeDiff = abs(energyModelDate.timeIntervalSince1970 - timestamp)
            if timeDiff < smallestTimeDiff {
                smallestTimeDiff = timeDiff
                closestEnergyModel = energyModel
            }
        }
        
        print("Closest energy model for timestamp \(timestamp): \(closestEnergyModel?.timestamp ?? "Not found")")
        return closestEnergyModel
    }
    
    /**
    Calculates the cost of energy based on energy usage and an energy model.

   - Parameters:

    - energyUsage: A Double value, representing the energy consumption in a specific period.
    - energyModel: An EnergyModel object, representing the energy pricing model used to calculate the cost.
     
    - Returns:
     -  a Double value, representing the calculated cost of energy.

    The function calculates the cost by multiplying the energyUsage by the overall property of the energyModel. It then prints the calculated cost and returns the value.
    */
    func energyCost(energyUsage: Double, energyModel: EnergyModel) -> Double {
        let cost = energyModel.overall * energyUsage
        print("Energy cost for usage \(energyUsage) and model \(energyModel.overall): \(cost)")
        return cost
    }
    
    
}


