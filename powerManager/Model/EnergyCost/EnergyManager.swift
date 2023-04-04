//
//  EnergyManager.swift
//  powerManager
//
//  Created by Paul Olphert on 16/02/2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct EnergyManager {
    /**
    Calls the energy cost API with the start date, end date, DNO, and voltage as set by the user in the Setup and StatisticsViewController.

    - Parameters:

     - startDate: A Date object, representing the start date of the range for which the energy data should be fetched.
     - endDate: A Date object, representing the end date of the range for which the energy data should be fetched.
     
    - Completion: A closure that takes an optional array of EnergyModel objects as input
        - Returns: Void.
     
    The function first prints the received start and end dates, and initializes a DateFormatter object with the format "dd-MM-yyyy". It then converts the start and end dates to strings using the date formatter. The function proceeds to fetch energy read data from Firestore for the current user's email, and retrieves the DNO and voltage values from the document.

    Next, the function fetches energy data from the API using the fetchEnergyData function, passing the DNO, voltage, start date, and end date as parameters. Upon completion, the closure provided to fetchEnergyData is executed, and the fetched energy models are passed to the completion closure of the updateEnergyData function.
    */
    func updateEnergyData(startDate: Date, endDate: Date, completion: @escaping ([EnergyModel]?) -> Void) {
        print("The start date recieved by updateEnergyData is \(startDate) and the end date recieved is \(endDate)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        print("fetching Data from FireStore.. currently hold the startDate \(startDate) and endDate \(endDate)")
        // Get the energy read data from Firestore
        let db = Firestore.firestore()
        let userEmail = Auth.auth().currentUser?.email ?? ""
        let docRef = db.collection("energyReadCollection").document(userEmail)
        docRef.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else if let document = document, document.exists {
                let dno = document.get("dno") as? Int ?? 0
                let voltage = document.get("voltage") as? String ?? ""
                _ = document.get("user") as? String ?? ""
                
                // Fetch the energy data from the API
                print("Fetching energy data...with \(dno) and \(voltage) for startdate \(startDate) and endDate \(endDate)")
                // Fetch the energy data from the API
                fetchEnergyData(dno: dno, voltage: voltage, startDate: startString, endDate: endString) { energyModels in
                print("Finished fetching energy data")
                    completion(energyModels)
                }
            } else {
                //print("no document by the name \(document) exists")
                completion(nil)
            }
        }
    }

    
    /**
    Fetches energy data from the API using the specified DNO, voltage, start date, and end date.

    - Parameters:

     - dno: An Int value, representing the Distribution Network Operator code.
     - voltage: A String value, representing the voltage level (e.g., "LV" for low voltage).
     - startDate: A String value, representing the start date of the range for which the energy data should be fetched, in the format "dd-MM-yyyy".
     - endDate: A String value, representing the end date of the range for which the energy data should be fetched, in the format "dd-MM-yyyy".
     
    - Completion:
     - A closure that takes an optional array of EnergyModel objects as input
        - Returns:  Void.
     
    The function constructs the API URL using the provided parameters and sends an HTTP request to fetch energy data. It then checks whether the response contains valid data and no error. If so, it proceeds to parse the JSON response, extracting energy data and converting it into an array of EnergyModel objects. Finally, the function passes the array of EnergyModel objects to the completion closure. If any error occurs during the process, the function calls the completion closure with a nil value.
    */
    func fetchEnergyData(dno: Int, voltage: String, startDate: String, endDate: String, completion: @escaping ([EnergyModel]?) -> Void) {
        let urlString = "https://odegdcpnma.execute-api.eu-west-2.amazonaws.com/development/prices?dno=\(dno)&voltage=\(voltage)&start=\(startDate)&end=\(endDate)"
    //https://odegdcpnma.execute-api.eu-west-2.amazonaws.com/development/prices?dno=23&voltage=LV&start=14-02-2023&end=15-02-2023
        print("Call to for electricity cost data from the url \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let jsonDict = json as? [String: Any], let jsonData = jsonDict["data"] as? [String: Any], let energyData = jsonData["data"] as? [[String: Any]] {
                    let energyModels: [EnergyModel] = energyData.compactMap { data in
                        guard let overall = data["Overall"] as? Double, let unixTimestamp = data["unixTimestamp"] as? Double, let timestamp = data["Timestamp"] as? String else {
                            return nil
                        }
                        return EnergyModel(overall: overall, unixTimestamp: unixTimestamp, timestamp: timestamp)
                    }
                    completion(energyModels)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
}
