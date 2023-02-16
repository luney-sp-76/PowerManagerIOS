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
        
        // Get the energy read data from Firestore
        let db = Firestore.firestore()
        let userId = Auth.auth().currentUser?.uid
        let docRef = db.collection(K.FStore.energyread).document()
        docRef.getDocument { document, error in
            guard let document = document, document.exists, let dno = document.get("dno") as? String, let voltage = document.get("voltage") as? String else {
                // Handle the error case
                completion(nil)
                return
            }
            
            // Fetch the energy data from the API and send it to the caller
            fetchEnergyData(dno: dno, voltage: voltage, startDate: startString, endDate: endString) { energyModels in
                completion(energyModels)
            }
        }
    }

    
    // The fetchEnergyData method remains unchanged
    func fetchEnergyData(dno: String, voltage: String, startDate: String, endDate: String, completion: @escaping ([EnergyModel]?) -> Void) {
        let urlString = "https://odegdcpnma.execute-api.eu-west-2.amazonaws.com/development/prices?dno=\(dno)&voltage=\(voltage)&start=\(startDate)&end=\(endDate)"
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
