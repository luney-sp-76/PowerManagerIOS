//
//  ViewController.swift
//  powerManager
//
//  Created by Paul on 29/12/2022.
//

import UIKit
import FirebaseAuth

class BatteryMonitorViewController: UIViewController {
    
    var deviceManager = DeviceManager()
    var plugControl = PlugControl()
    var homeManager = HomeManager()
    var batteryPercentage = 21
    var plugColour = "off"
    
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    @IBOutlet weak var setBatteryLevel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var powerPlugIcon: UIImageView!
    
    var currentBatteryLevel = 100
    var lowestBatteryChargeLevel = 21
    var lastPlugStateCheckTime: Date = Date()
    var delegate: SettingsViewControllerDelegate?
    
    
    
    override func viewDidLoad() {
        title = K.appName
        navigationItem.hidesBackButton = true
        deviceManager.delegate = self
        let settingsController = SettingsViewController()
        settingsController.delegate = self
        deviceManager.fetchDeviceData(deviceName: V.iPhoneBatteryLevelEntityID)
        updatePlugColour(state: plugColour)
        scheduleFetchData()
    }
    
    @objc func checkPlugState(plugDevice: String) {
        deviceManager.fetchPlugState(urlEndPoint: plugDevice)
        
    }
    
    @objc func checkBatteryLevel(batteryDevice: String) {
        deviceManager.fetchDeviceData(deviceName: batteryDevice)
        print(V.iPhoneBatteryLevelEntityID)
      
    }
    
    func scheduleFetchData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            self.checkBatteryLevel(batteryDevice: V.iPhoneBatteryLevelEntityID)
            self.checkPlugState(plugDevice: V.plugStateEntityID)
            self.scheduleFetchData()
        }
    }
    
    
    func updatePlugColour(state: String) {
        //print(state)
        if state == "off" {
            powerPlugIcon.tintColor = UIColor(named: "PlugIconColourOff")
        }else {
            powerPlugIcon.tintColor = UIColor(named: "PlugIconColourOn")
        }
    }
    
    @objc func battery(level: String){
        print("should not print")
        
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        setBatteryLevel.textColor = UIColor(named: "NumberColor")
        button.isSelected = false
        button.setTitle("Set", for: .normal)
        lowestBatteryChargeLevel = Int(sender.value)
        //set a public variable of the users choice of batterylevel to access outside of the viewcontroller
        V.usersSetBatteryLevel =  lowestBatteryChargeLevel
        // make the set level into text
        setBatteryLevel.text = String(format: "%d",  lowestBatteryChargeLevel)
        currentBatteryLevel = Int(batteryPercentageLabel.text ?? "0")!
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        // change button text to set level
        sender.isSelected = true
        setBatteryLevel.textColor = UIColor(named: "AffirmAction")
        sender.setTitle("Done", for: .normal)
    }
    
    
    
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            //jumps back to the root page
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
}

//MARK: - DeviceManagerDelegate

extension BatteryMonitorViewController: DeviceManagerDelegate {
    
    
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel) {
        DispatchQueue.main.async { [self] in
            if device.name == V.iPhoneBatteryLevelFriendlyName {
                //change battery percentage to current battery percentage state
                self.batteryPercentageLabel.text = device.state
                currentBatteryLevel = Int(device.state) ?? Int(batteryPercentageLabel.text!)!
                if currentBatteryLevel <= lowestBatteryChargeLevel || currentBatteryLevel == 100  {
                    plugColour = deviceManager.manageBattery(device: device, lowestBatteryChargeLevel: lowestBatteryChargeLevel, currentBatteryLevel: currentBatteryLevel)
                    updatePlugColour(state: plugColour)
                }
            }
            let timeSinceLastCheck = Date().timeIntervalSince(lastPlugStateCheckTime)
            if timeSinceLastCheck > 30 {
                lastPlugStateCheckTime = Date()
            }
            if device.name == V.plugFriendlyName {
                updatePlugColour(state: device.state)
            }
        }
    }
}



//MARK: - PlugControlDelegate

extension BatteryMonitorViewController: PlugManagerDelegate {
    func didUpdateDevice(_ PlugManager: PlugControl){
        print("updated")
    }
    
    func didFailWithError(error: Error){
        print(error)
    }
}

//MARK: - SettingsViewControllerDelegate

extension BatteryMonitorViewController: SettingsViewControllerDelegate {
        func didSelectDevice(_ deviceName: String) {
          
            if deviceName.contains("battery_level"){
                print("\(deviceName) is now the batterydevice")
                V.iPhoneBatteryLevelEntityID = deviceName
                print(V.iPhoneBatteryLevelEntityID)
            }else{
                print("\(deviceName) is now the plugdevice")
                V.plugStateEntityID = deviceName
                print(V.plugStateEntityID)
            }
        }
    
}
