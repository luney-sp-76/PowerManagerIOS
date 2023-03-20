//
//  EnergyManagerTests.swift
//  powerManagerTests
//
//  Created by Paul Olphert on 20/03/2023.
//

import XCTest
import Firebase

final class EnergyManagerTests: XCTestCase {

        var energyManager: EnergyManager!

        override func setUp() {
            super.setUp()
            FirebaseApp.configure()
            energyManager = EnergyManager()
        }

        override func tearDown() {
            energyManager = nil
            super.tearDown()
        }
    
//In this test case, we create an EnergyManager instance and call the updateEnergyData method with a start date and an end date. We then wait for an asynchronous expectation to be fulfilled and assert that the returned energyModels array is not nil.
        func testUpdateEnergyData() {
            let expectation = XCTestExpectation(description: "Fetch energy data from API")
            let startDate = Date()
            let endDate = Date()
            energyManager.updateEnergyData(startDate: startDate, endDate: endDate) { energyModels in
                XCTAssertNotNil(energyModels)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    
    //In this test case, we create an EnergyManager instance and call the fetchEnergyData method with the parameters dno, voltage, startDate, and endDate. We then wait for an asynchronous expectation to be fulfilled and assert that the returned energyModels array is not nil. You can adjust the values of these parameters to test different scenarios.
    func testFetchEnergyData() {
            let expectation = XCTestExpectation(description: "Fetch energy data from API")
            let dno = 23
            let voltage = "LV"
            let startDate = "14-02-2023"
            let endDate = "15-02-2023"
            energyManager.fetchEnergyData(dno: dno, voltage: voltage, startDate: startDate, endDate: endDate) { energyModels in
                XCTAssertNotNil(energyModels)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }


