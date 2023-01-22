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
        DeviceModel(id: "iphone", state: "full", name: "iphone_8_no_1", lastUpdate: "yesterday", uuid: "1234"),
        DeviceModel(id: "plug", state: "on", name: "develco", lastUpdate: "yesterday", uuid: "5678")]
    
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
        print(indexPath.row)
    }

}


