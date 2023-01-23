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
    
    
    var deviceInfo: [DeviceModel] = [
        DeviceModel(id: "sensor.iphone_8_number_1", state: "80", name: "iPhone 8 Number 1 Battery Level", lastUpdate: "yesterday", uuid: "1234"),
        DeviceModel(id: "switch.0x0015bc002f00edf3", state: "on", name: "develco", lastUpdate: "yesterday", uuid: "5678")]
    
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
    func didUpdateDevice(_ homeManager: HomeManager, device: DeviceModel) {
        DispatchQueue.main.async { [self] in
           print(device.name)
            self.deviceInfo.append(device)
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
        cell.label.text = deviceInfo[indexPath.row].name
        return cell
    }
    
    
}


//MARK: - TableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var device_id = deviceInfo[indexPath.row].id
        if device_id.contains("sensor"){
            print("its a phone")
        }else if device_id.contains("switch"){
            print("its a plug")
        }
    }

}


