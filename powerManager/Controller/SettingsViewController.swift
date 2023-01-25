//
//  SettingsViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 15/01/2023.
//

import UIKit

class SettingsViewController: UIViewController {
  

    
   var homeManager = HomeManager()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var deviceInfo: [HomeAssistantData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        homeManager.delegate = self
        title = K.appName
        tableView.register(UINib(nibName: K.celNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        //navigationItem.hidesBackButton = true
    }
    
}

//MARK: - HomeManagerDelegate

extension SettingsViewController: HomeManagerDelegate {
    func didReceiveDevices(_ devices: [HomeAssistantData]) {
        DispatchQueue.main.async { [self] in
            print(devices[0].entity_id)
            self.deviceInfo.append(contentsOf: devices)
            }
       
    }
    
    func didFailWithError(error: Error) {
       print(error)
    }
    
}

//MARK: - UITABLEVIEWDATASOURCE

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        deviceInfo.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! DevicesCell
        cell.label.text = deviceInfo[indexPath.row].attributes.friendlyName
        return cell
    }
    
    
}


//MARK: - TableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device_id = deviceInfo[indexPath.row].attributes.friendlyName
        if device_id.contains("iphone"){
            V.iPhoneBatteryLevelEntityID = device_id
            print("You set \(V.iPhoneBatteryLevelEntityID) as the battery device")
        }else if device_id.contains("switch"){
            V.plugFriendlyName = device_id
            print("You set \( V.plugFriendlyName) as the smart plug device")
        }
    }

}


