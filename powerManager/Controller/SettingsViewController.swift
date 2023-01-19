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
    
    
    var deviceInfo: [DeviceModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeManager.delegate = self
        title = K.appName
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
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        cell.textLabel?.text = "this is a cell"
        return cell
    }
    
    
}


