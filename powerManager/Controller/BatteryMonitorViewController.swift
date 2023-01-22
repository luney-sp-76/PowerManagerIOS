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
    var batteryPercentage = 21
    var plugColour = "off"
    
    
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    @IBOutlet weak var setBatteryLevel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var powerPlugIcon: UIImageView!
    
    var currentBatteryLevel = 100
    var lowestBatteryChargeLevel = 21
    
    
    override func viewDidLoad() {
        title = K.appName
        navigationItem.hidesBackButton = true
        deviceManager.delegate = self
        //initial call for battery percentage level on load
        deviceManager.fetchDeviceData(deviceName: "sensor.iphone_8_number_1", urlEndPoint: "_battery_level")
        updatePlugColour(state: plugColour)
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
        batteryPercentage = Int(sender.value)
        setBatteryLevel.text = String(format: "%d", batteryPercentage)
        currentBatteryLevel = Int(batteryPercentageLabel.text ?? "0")!
        lowestBatteryChargeLevel = Int(setBatteryLevel.text!)!
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        // change button text to set level
        sender.isSelected = true
        setBatteryLevel.textColor = UIColor(named: "AffirmAction")
        sender.setTitle("Done", for: .normal)
    }
    
    func getSetBatteryLevel() -> Int {
        return batteryPercentage
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
            // if device is not identified here the batterypercentage will take on the plug state too ie on or off
            if device.name == "iPhone 8 Number 1 Battery Level"{
                //change battery percentage to current battery percentage state
                self.batteryPercentageLabel.text = device.state
                currentBatteryLevel = Int(device.state) ?? Int(batteryPercentageLabel.text!)!
                //print(device.name)
            }
            //call for the plugs state
            deviceManager.fetchPlugState(urlEndPoint: "switch.0x0015bc002f00edf3")
            if device.name == "develco"{
                updatePlugColour(state: device.state)
            }
            plugColour = deviceManager.manageBattery(device: device, lowestBatteryChargeLevel: lowestBatteryChargeLevel)
//            if currentBatteryLevel >= 100 && device.name == "develco" && device.state == "on" {
//                self.plugControl.fetchPlugData(deviceName: "switch.0x0015bc002f00edf3/", urlEndPoint: "turn_off")
//                plugColour = "off"
                updatePlugColour(state: device.state)

//            } else if currentBatteryLevel <= lowestBatteryChargeLevel && device.name == "develco" && device.state == "off"{
//                self.plugControl.fetchPlugData(deviceName: "switch.0x0015bc002f00edf3/", urlEndPoint: "turn_on")
//                plugColour = "on"
//                updatePlugColour(state: device.state)
//            }
        }
        //create a 30 second delay between calls to allow updates to plug state to register
        sleep(UInt32(30.00))
        //recheck the battery percentage level
        let timer = Timer.scheduledTimer(timeInterval: 6000.00, target: self, selector: #selector(self.battery), userInfo:deviceManager.fetchDeviceData(deviceName: "sensor.iphone_8_number_1", urlEndPoint: "_battery_level") , repeats: true)
        //common mode allows multithreading in order for other api calls to be made
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
}

//MARK: - PlugControlDelegate

extension BatteryMonitorViewController: PlugManagerDelegate {
    func didUpdateDevice(_ PlugManager: PlugControl){
        print("updated")
    }
    
    func didFailWithError(_ error: Error){
        print(error)
    }
}
//MARK: - Task extension sleep(seconds)

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

