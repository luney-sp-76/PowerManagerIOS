//
//  SettingsViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 15/01/2023.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var homeManager = HomeManager()
    var deviceInfo: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeManager.delegate = self
        homeManager.fetchDeviceData()
        tableView.dataSource = self
        tableView.delegate = self
        title = K.appName
        tableView.register(UINib(nibName: K.celNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        //navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //homeManager.fetchDeviceData()
    }
}

//MARK: - HomeManagerDelegate

extension SettingsViewController: HomeManagerDelegate {
    func didReceiveDevices(_ devices: [String]) {
        DispatchQueue.main.async {[self] in
            if !devices.isEmpty {
                self.deviceInfo = devices
                self.tableView.reloadData()
            }
            }
        }
    }

    
    func didFailWithError(error: Error) {
        print(error)
    }

//MARK: - UITABLEVIEWDATASOURCE

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableview \(self.deviceInfo.count)")
        return self.deviceInfo.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! DevicesCell
        cell.label.text = deviceInfo[indexPath.row]
        return cell
    }
    
    
}


//MARK: - TableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device_id = deviceInfo[indexPath.row]
        if device_id.contains("iphone"){
            V.iPhoneBatteryLevelEntityID = device_id
            print("You set \(V.iPhoneBatteryLevelEntityID) as the battery device")
        }else if device_id.contains("switch"){
            V.plugFriendlyName = device_id
            print("You set \( V.plugFriendlyName) as the smart plug device")
        }
    }
    
}


