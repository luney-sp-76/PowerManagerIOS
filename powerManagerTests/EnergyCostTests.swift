//
//  EnergyCostTests.swift
//  powerManagerTests
//
//  Created by Paul Olphert on 20/03/2023.
//

import XCTest
@testable import powerManager

final class EnergyCostTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddition() {
        let result = 2 + 2
        XCTAssertEqual(result, 4, "Addition test failed: Expected 4, got \(result)")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
