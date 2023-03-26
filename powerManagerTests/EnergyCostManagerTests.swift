//
//  EnergyCostManagerTests.swift
//  powerManagerTests
//
//  Created by Paul Olphert on 20/03/2023.
//

import XCTest
import Charts
@testable import powerManager
@testable import Pods_powerManager

class EnergyCostDataManagerTests: XCTestCase {
    var energyCostDataManager: EnergyCostDataManager!
    
    override func setUp() {
        super.setUp()
        energyCostDataManager = EnergyCostDataManager()
    }
    
    override func tearDown() {
        energyCostDataManager = nil
        super.tearDown()
    }
    
    func testTotalCostCalculation() {
        // Prepare your test data
        let energyModels = [
            EnergyModel(overall: 0.1, unixTimestamp: 1675734000, timestamp: "2023-03-20T10:00:00.000000Z"),
            // Add more EnergyModel instances as needed
        ]
        let energyReadings = [
            HomeData(user: "1@2.com", entity_id: "device_1_energy", state: "100", lastUpdated: "2023-03-20T10:00:00.000000Z", friendlyName: "test_name", uuid: "test"),
            // Add more HomeData instances as needed
        ]
       //let chartView = LineChartView()
       let dateValueFormatter = DateValueFormatter()

        // Call the method you want to test
       //let result = energyCostDataManager.combineEnergyData(energyModels: energyModels, energyReadings: energyReadings, chartView: chartView, dateValueFormat: dateValueFormatter)

        // Assert the total cost is correct
       //XCTAssertEqual(result.totalCost, 10, "Total cost calculation failed")
    }
    
    func testFilteredEnergyReadings() {
        //
    }
}
