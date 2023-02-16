//
//  EnergyManager.swift
//  powerManager
//
//  Created by Paul Olphert on 16/02/2023.
//

import Foundation
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
