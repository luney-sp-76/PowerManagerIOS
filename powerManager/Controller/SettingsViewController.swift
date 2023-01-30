//
//  SettingsViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 15/01/2023.
//

import UIKit

protocol BatteryMonitorViewControllerDelegate {
func updateDevices(battery: String, plug: String)
}
var batteryDelegate: BatteryMonitorViewControllerDelegate?

class SettingsViewController: UIViewController {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var homeManager = HomeManager()
    var delegate: BatteryMonitorViewControllerDelegate?
    
    //all the data from homeassistant
    var deviceInfo: [HomeAssistantData] = []
    //should hold 2 devices from homeassisatnt
    var selectedDevices: [String] = []
    //the homeassisant device entity_id for a battery powered device
    
 
    var batteryDevice: String = ""
    //the homeassisant device entity_id for a smart plug device
    var plugDevice: String = ""
    // how many devices are selected in the tableview
    var devicesSelected: Int = 0
    // is a selected device a battery device
    var batteryDeviceSelected = false
    // is a  selected device a smartplug device
    var switchDeviceSelected = false
    
    //testing count
    //var count = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initate this vew a s homeManager delegate
        homeManager.delegate = self
        // call the home manager method to fetchData from the API
        homeManager.fetchDeviceData()
        // set this view as the source of the table data
        tableView.dataSource = self
        // set this view as the delegate for tableview data
        tableView.delegate = self
        //register this tableview with the cellNames and ReuseIdentifier
        tableView.register(UINib(nibName: K.celNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        // add the app name to the Navigation Bar Title
        title = K.appName
        //navigationItem.hidesBackButton = true
    }
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        //print("when the set button was pressed count = \(count)")
        //print("and the array looks like this \(selectedDevices)")
            sender.isSelected = true
        performSegue(withIdentifier: K.settingsToBatteryMonitor, sender: self)
            }
            
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let destination = segue.destination as? BatteryMonitorViewController {
                destination.devicesArray = selectedDevices
            }
        
    }
}

//MARK: - HomeManagerDelegate
// manage the data from the HomeManager and create the data for deviceInfo from the array of Devices
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
        return self.deviceInfo.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! DevicesCell
        let device_id = deviceInfo[indexPath.row].entity_id
        cell.label.text = deviceInfo[indexPath.row].attributes.friendlyName
        //change the image to the right of the cell
        if deviceInfo[indexPath.row].entity_id.contains("battery_level") {
            cell.rightImageView.image = UIImage(named: "smartphone-charger")
        } else if deviceInfo[indexPath.row].entity_id.contains("switch") {
            cell.rightImageView.image = UIImage(named: "power-plug")
        }
        //checkmark the selected devices
        if selectedDevices.contains(device_id) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        return cell
    }
    
    
   
   
    
}


//MARK: - TableViewDelegate
//This code first checks if the selected device contains "battery_level" or "switch" and then checks if the selectedDevices array already contains that type of device. If it does, it removes the existing device and adds the new one. If it doesn't, it simply adds the new device to the array.
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DevicesCell
        let device_id = deviceInfo[indexPath.row].entity_id
        //print("\(selectedDevices) first check of the array")
        if device_id.contains("battery_level") {
            if !batteryDeviceSelected {
                selectedDevices.append(device_id)
                batteryDevice = device_id
                batteryDeviceSelected = true
            } else {
                // remove the existing battery device from the array
                if let index = selectedDevices.firstIndex(of: device_id) {
                    selectedDevices.remove(at: index)
                    cell.isSelected = false
                 //count -= 1
                   // print(count)
                }
                batteryDeviceSelected = false
                //print("You deselected the battery device")
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
               
            }
        } else if device_id.contains("switch") {
            if !switchDeviceSelected {
                selectedDevices.append(device_id)
                plugDevice = device_id
               
                switchDeviceSelected = true
                //print("You set \(device_id) as the smart plug device")
                //print("\(selectedDevices) potential second check of the array")
                //count += 1
                //print(count)
            } else {
                // remove the existing switch device from the array
                if let index = selectedDevices.firstIndex(of: device_id) {
                    selectedDevices.remove(at: index)
                    //count -= 1
                    //print(count)
                    cell.isSelected = false
                }
                switchDeviceSelected = false
               // print("You deselected the smart plug device")
                //print("\(selectedDevices) if you changed your mind then maybe second or greater check of the array")
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
        
        DispatchQueue.main.async {
            tableView.reloadData()
        }
    }
}





    

    

//Attributted Icons
//<a href="https://www.flaticon.com/free-icons/full-battery" title="full battery icons">Full battery icons created by Pixel perfect - Flaticon</a>
//<a href="https://www.flaticon.com/free-icons/plug" title="plug icons">Plug icons created by Flat Icons - Flaticon</a>


