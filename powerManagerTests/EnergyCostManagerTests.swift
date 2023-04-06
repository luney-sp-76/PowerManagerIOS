//
//  EnergyCostManagerTests.swift
//  powerManager
//
//  Created by Paul Olphert on 06/04/2023.
//

import XCTest
import Charts
@testable import powerManager
//@testable import Pods_powerManager


final class EnergyCostManagerTests: XCTestCase {

    var energyCostDataManager: EnergyCostDataManager!

    override func setUp() {
        super.setUp()
        energyCostDataManager = EnergyCostDataManager()
        
    }
    
    
    func testCombineEnergyData() {
        
        // Create a sample EnergyModel array
        let energyModels: [EnergyModel] = [
        // Add EnergyModel instances here
         ]
        
         //Create a sample HomeData array
         let homeData: [HomeData] = [
         //Add HomeData instances here
         ]
        
        // Create a LineChartView instance
        let chartView = LineChartView()
        
        // Create a DateValueFormatter instance
        let dateValueFormat = DateValueFormatter()
        
        // Define the start and end dates
        let secondsInADay: TimeInterval = 86400
        let sevenDaysAgoTimestamp = Date().timeIntervalSince1970 - (secondsInADay * 7)
        
        let startDate = Date(timeIntervalSince1970: sevenDaysAgoTimestamp)
        
        let endDate = Date()
        
        // Define expected results
        let expectedChartDataEntriesCount = 7 // the expected chart data entries count
        let expectedTotalCost = 1.60//the expected total cost
        
        // Call the combineEnergyData function and store the result
        //            let result = energyCostDataManager.combineEnergyData(energyModels: energyModels, homeData: homeData, chartView: chartView, dateValueFormat: dateValueFormat, startDate: startDate, endDate: endDate)
        
        // Verify the result (e.g., chartDataEntries count, totalCost value)
        //            XCTAssertEqual(result.chartDataEntries.count, expectedChartDataEntriesCount, "Unexpected chart data entries count")
        //            XCTAssertEqual(result.totalCost, expectedTotalCost, accuracy: 0.001, "Unexpected total cost value")
    }
    
    
    
    func testFilteredSwitchStates() {
        // Prepare test data for homeData, startDate, and endDate
        // ...
        // Create a sample HomeData array
        //let homeData: [HomeData] = [
        // Add HomeData instances here
        //]
        
        
        // Define the start and end dates
        let secondsInADay: TimeInterval = 86400
        let sevenDaysAgoTimestamp = Date().timeIntervalSince1970 - (secondsInADay * 7)
        
        let startDate = Date(timeIntervalSince1970: sevenDaysAgoTimestamp)
        
        let endDate = Date() // Replace YYY with the desired end date
        
        //           let result = energyCostDataManager.filteredSwitchStates(homeData: homeData, startDate: startDate, endDate: endDate)
        
        // Verify the result (e.g., filtered switch states count)
        //XCTAssertEqual(result.count, 3, "Unexpected filtered switch states count")
    }
    override func tearDown() {
        energyCostDataManager = nil
        super.tearDown()
    }
}

