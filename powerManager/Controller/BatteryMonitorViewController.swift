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
    
    
    override func viewDidLoad() {
        title = K.appName
        navigationItem.hidesBackButton = true
        deviceManager.delegate = self
        //if the iPhoneBatteryLevelEntityID is "" make an alert to go to settings else call fetchDevice data
        //varaible for iPhoneBatteryLevelEntityID should be initiated as ""
        //initial call for battery percentage level on load
        deviceManager.fetchDeviceData(deviceName: V.iPhoneBatteryLevelEntityID, urlEndPoint: K.batteryLevelEndPoint)
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
    
//    func getSetBatteryLevel() -> Int {
//        return batteryPercentage
//    }
    
    
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
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel){
        DispatchQueue.main.async { [self] in
            // if device is not identified here the batterypercentage will take on the plug state too ie on or off
            if device.name == V.iPhoneBatteryLevelFriendlyName {
                //change battery percentage to current battery percentage state
                self.batteryPercentageLabel.text = device.state
                currentBatteryLevel = Int(device.state) ?? Int(batteryPercentageLabel.text!)!
                //print(device.name)
            }
            //call for the plugs state
            deviceManager.fetchPlugState(urlEndPoint: V.plugStateEntityID)
            if device.name == V.plugFriendlyName {
                updatePlugColour(state: device.state)
            }
            plugColour = deviceManager.manageBattery(device: device, lowestBatteryChargeLevel: lowestBatteryChargeLevel)
                updatePlugColour(state: device.state)
        }
        //create a 30 second delay between calls to allow updates to plug state to register
        sleep(UInt32(60.00))
        //recheck the battery percentage level
        let timer = Timer.scheduledTimer(timeInterval: 6000.00, target: self, selector: #selector(self.battery), userInfo:deviceManager.fetchDeviceData(deviceName: V.iPhoneBatteryLevelEntityID, urlEndPoint: K.batteryLevelEndPoint) , repeats: true)
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

