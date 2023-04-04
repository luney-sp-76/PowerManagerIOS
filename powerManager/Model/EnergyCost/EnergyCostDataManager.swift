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

        /// Filter switch states within the specified date range.
        func filteredSwitchStates(homeData: [HomeData], startDate: Date, endDate: Date) -> [HomeData] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
            
            let filteredData = homeData.filter { $0.entity_id.contains("switch") && dateFormatter.date(from: $0.lastUpdated)?.timeIntervalSince1970 ?? 0 >= startDate.timeIntervalSince1970 && dateFormatter.date(from: $0.lastUpdated)?.timeIntervalSince1970 ?? 0 <= endDate.timeIntervalSince1970 }
            
            print("Filtered switch states count: \(filteredData.count)")
            return filteredData
        }

        /// Find the closest energy reading to the given timestamp.
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

        /// Find the closest energy model to the given timestamp.
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

        /// Calculate the cost of energy based on energy usage and energy model.
        func energyCost(energyUsage: Double, energyModel: EnergyModel) -> Double {
            let cost = energyModel.overall * energyUsage
            print("Energy cost for usage \(energyUsage) and model \(energyModel.overall): \(cost)")
            return cost
        }


    }


