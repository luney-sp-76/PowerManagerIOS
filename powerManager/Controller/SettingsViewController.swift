//
//  SettingsViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 15/01/2023.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didSelectDevice(_ device: String)
}

class SettingsViewController: UIViewController {
 
    
   
    
  
    @IBOutlet weak var tableView: UITableView!
    var homeManager = HomeManager()
    var deviceInfo: [HomeAssistantData] = []
    var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeManager.delegate = self
        let settingsController = SettingsViewController()
        settingsController.delegate = self
        homeManager.fetchDeviceData()
        tableView.dataSource = self
        tableView.delegate = self
        title = K.appName
        tableView.register(UINib(nibName: K.celNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        //navigationItem.hidesBackButton = true
    }
    
  
    
    
}

//MARK: - HomeManagerDelegate

extension SettingsViewController: HomeManagerDelegate {

    func didReceiveDevices(_ devices: [HomeAssistantData]) {
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
        cell.label.text = deviceInfo[indexPath.row].attributes.friendlyName
        if deviceInfo[indexPath.row].entity_id.contains("battery_level") {
            cell.rightImageView.image = UIImage(named: "smartphone-charger")
        } else if deviceInfo[indexPath.row].entity_id.contains("switch") {
            cell.rightImageView.image = UIImage(named: "power-plug")
        }
        return cell
    }
    
    
}


//MARK: - TableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let device_id = deviceInfo[indexPath.row].entity_id
        if device_id.contains("battery_level"){
          
            print("You set \(device_id) as the battery device")
            delegate?.didSelectDevice(device_id)
        }else if device_id.contains("switch"){
         
            print("You set \( device_id) as the smart plug device")
            delegate?.didSelectDevice(device_id)
        }
    }
    
}
extension SettingsViewController: SettingsViewControllerDelegate {
    func didSelectDevice(_ device: String) {
      
    }

    
    
}
//Attributted Icons
//<a href="https://www.flaticon.com/free-icons/full-battery" title="full battery icons">Full battery icons created by Pixel perfect - Flaticon</a>
//<a href="https://www.flaticon.com/free-icons/plug" title="plug icons">Plug icons created by Flat Icons - Flaticon</a>


