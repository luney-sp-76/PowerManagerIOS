import XCTest
@testable import powerManager
import FirebaseAuth
import FirebaseFirestore

class EnergyManagerTests: XCTestCase {
    
    // Mocks
    
    class FirestoreMock: Firestore {
        //...
    }
    
    class URLSessionDataTaskMock: URLSessionDataTask {
        //...
    }
    
    class URLSessionMock: URLSession {
        //...
    }
    
    // Test data
    
    func getTestEnergyModel() -> [EnergyModel] {
        return [EnergyModel(overall: 100.0, unixTimestamp: 1617004800, timestamp: "01-04-2021")]
    }
    
    // Tests
    
    func testUpdateEnergyData() {
        // Set up your mocks and expectations
        // ...
        
        let energyManager = EnergyManager()
        let startDate = Date(timeIntervalSince1970: 1617004800)
        let endDate = Date(timeIntervalSince1970: 1617091200)
        
        energyManager.updateEnergyData(startDate: startDate, endDate: endDate) { energyModels in
            XCTAssertNotNil(energyModels, "EnergyModels should not be nil")
            XCTAssertEqual(energyModels, self.getTestEnergyModel(), "EnergyModels should match test data")
        }
    }
    
    func testFetchEnergyData() {
        // Set up your mocks and expectations
        // ...
        
        let energyManager = EnergyManager()
        let startDate = "01-04-2021"
        let endDate = "02-04-2021"
        
        energyManager.fetchEnergyData(dno: 23, voltage: "LV", startDate: startDate, endDate: endDate) { energyModels in
            XCTAssertNotNil(energyModels, "EnergyModels should not be nil")
            XCTAssertEqual(energyModels, self.getTestEnergyModel(), "EnergyModels should match test data")
        }
    }
}
