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
    
    
    @IBOutlet weak var setUpButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    let securedData = SecuredDataFetcher()
    let homeManager = HomeManager()
    var delegate: BatteryMonitorViewControllerDelegate?
    
    //all the battery level and plug devicesfrom homeassistant
    var deviceInfo: [HomeAssistantData] = []
    //should hold 2 device entity ids from homeassisatnt
    var selectedDevices: [String] = []
    //an array of battery_state devices
    var allBatteryStateDevices: [HomeAssistantData] = []
    // the variable returned to Battery Monitor to call for the correct charging state of the phone
    var selectedDeviceBatteryStateId: String = ""
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
        let setupButton = UIBarButtonItem(title: "Setup", style: .plain, target: self, action: #selector(self.setupButtonTapped))
                navigationItem.rightBarButtonItem = setupButton
        // initate this vew a s homeManager delegate
        homeManager.delegate = self
      
        // call the home manager method to fetchData from the API
        print(("settingsView Calls Home Manager"))
        homeManager.fetchDeviceData { result in
                    switch result {
                    case .success(let devices):
                        self.deviceInfo = devices.filter { device in
                            return device.entity_id.contains(K.batteryLevel) || device.entity_id.contains(K.switchs)
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print("Failed to fetch device data: \(error.localizedDescription)")
                    }
                }
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
    
    //lock the screen orientation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    //removes the contstraint on orientation lock from portrait back to all
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    @objc func setupButtonTapped() {
           // Handle setup button tap here
           // For example, perform a segue to the setup view controller
        performSegue(withIdentifier: K.settingsToSetup, sender: self)
       }
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        //print("when the set button was pressed count = \(count)")
        //print("and the array looks like this \(selectedDevices)")
        sender.isSelected = true
        performSegue(withIdentifier: K.settingsToBatteryMonitor, sender: self)
    }
    //sends the choosen devices to the device array in batterymonitorViewController and updates the batterystate variable for api calls
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BatteryMonitorViewController {
        
            destination.updateDevicesArray(newDevicesArray: selectedDevices)
            //destination.devicesArray = selectedDevices
            destination.iPhoneBatteryStateEntityID = selectedDeviceBatteryStateId
        }
        
    }
    
    
    @IBAction func setUpButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.settingsToSetup, sender: self)
    }
    
    
    
}

//MARK: - HomeManagerDelegate
// manage the data from the HomeManager and create the data for deviceInfo from the array of Devices
extension SettingsViewController: HomeManagerDelegate {
    func didFailToFetchDeviceData(with error: Error) {
        print("Failed to fetch device data: \(error.localizedDescription)")
    }
    func didReceiveDevices(_ devices: [HomeAssistantData]) {
        DispatchQueue.main.async { [self] in
            if !devices.isEmpty {
                for device in devices {
                   if device.entity_id.contains("battery_state") {
                        self.allBatteryStateDevices.append(device)
                    }
                }
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
        if deviceInfo[indexPath.row].entity_id.contains(K.batteryLevel) {
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
    
    // this func uses known knowledge that the string cannot be empty as it should not be called
    // but will return an empty string if its called with an empty string
    // the function expects a string that starts with sensor. so offsets at character 7
    //it expects a named device followed by battery_level so a minimum of 1 letter and _ beforehand
    // I have set it to end at character 17 which would encompass the word battery but no futher
    //this will return the substring between these two points
    func setBatteryStateDevice(entity: String) -> String {
        if !entity.isEmpty{
            let str = entity
            let startIndex = str.index(str.startIndex, offsetBy: 7)
            let endIndex = str.index(str.startIndex, offsetBy: 17)
            let substringEndIndex = min(endIndex, str.endIndex)
            let substring = str[startIndex..<substringEndIndex]
            return String(substring)
            
        }
        return " "
       
    }
    
    
    
    
}


//MARK: - TableViewDelegate
//This code first checks if the selected device contains "battery_level" or "switch" and then checks if the selectedDevices array already contains that type of device. If it does, it removes the existing device and adds the new one. If it doesn't, it simply adds the new device to the array.
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DevicesCell
        let device_id = deviceInfo[indexPath.row].entity_id
        //print("\(selectedDevices) first check of the array")
        if device_id.contains(K.batteryLevel) {
            if !batteryDeviceSelected {
                // add the new battery device to the array of selected devices
                selectedDevices.append(device_id)
                //from the entity id of the battery device check the entity id from after sensor.
                let subString = setBatteryStateDevice(entity: device_id)
                for device in allBatteryStateDevices {
                    //if the allBatteryStateDevices contains that substring
                    if device.entity_id.contains(subString) {
                        //make the baterystate id this device
                        selectedDeviceBatteryStateId = device.entity_id
                       // print(selectedDeviceBatteryStateId)
                    }
                }
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
        } else if device_id.contains(K.switchs) {
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


