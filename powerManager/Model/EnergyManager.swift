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
    // call the energy cost api with the startdate and end date and dno and voltage as set by the user in Setup and in the statisticsviewcontroller
    func updateEnergyData(startDate: Date, endDate: Date, completion: @escaping ([EnergyModel]?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        print("fetching Data from FireStore.. currently hold the startDate \(startDate) and endDate \(endDate)")
        // Get the energy read data from Firestore
        let db = Firestore.firestore()
        let userEmail = Auth.auth().currentUser?.email ?? ""
        let docRef = db.collection("energyReadCollection").document("energydatadocument")
        docRef.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else if let document = document, document.exists {
                let dno = document.get("dno") as? Int ?? 0
                let voltage = document.get("voltage") as? String ?? ""
                let userEmail = document.get("user") as? String ?? ""
                
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

    
    // The fetchEnergyData method remains unchanged
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
