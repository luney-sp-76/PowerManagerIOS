//
//  ViewController.swift
//  powerManager
//
//  Created by Paul on 29/12/2022.
//

import UIKit
import SwiftUI
import FirebaseAuth
import CLTypingLabel


class BatteryMonitorViewController: UIViewController {
   
    //ensure the viewDidLoad only happens once on each occasion
    private var viewHasLoaded = false
    // initiate DeviceManager
    var deviceStateManager = DeviceManager()
    //initiate PlugControl
    var plugControl = PlugControl()
    //initial HomeManager
    //var homeManager = HomeManager()
    var dataProvider = DataProvider()
    // to hold the devies selected in settings
    var devicesArray: [String] = []
    // a boolean to manage the async schedule in the scheduleFetchData function
    var shouldStop = false
    
    var batteryPercentage = 21
    // Declare the delegate property in BatteryMonitorViewController
    var plugColour = "off"
    var iPhoneBatteryLevelEntityID = " "
    var iPhoneBatteryStateEntityID = " "
    var plugStateEntityID = " "
    var devicesArraySemaphore = DispatchSemaphore(value: 1)
    var timer: Timer?
    var checked = false
    var count = 0
    
    
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    @IBOutlet weak var setBatteryLevel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var powerPlugIcon: UIImageView!
    @IBOutlet weak var iPhoneBatteryDeviceName: CLTypingLabel!
    @IBOutlet weak var plugName: CLTypingLabel!
    
    var currentBatteryLevel = 100
    var lowestBatteryChargeLevel = 21
    var lastPlugStateCheckTime: Date = Date()
    
    
    override func viewDidLoad() {
        title = K.appName
        navigationItem.hidesBackButton = true
        deviceStateManager.delegate = self
        checkDataHasLoaded()
    }
    
    
    /**
     this function checks if there are a battery_level and switch device in the devices Array
    
     - it updates the variables for iPhoneBatteryLevelEntityID and  plugStateEntityID with the data from the array
     - if iPhoneBatteryLevelEntityID is not present or has no value the user is prompted to add devices and pointed to the SettingsViewController via the segue
     */
    func checkDataHasLoaded() {
        //print("The array of devices chosen in settings is now \(devicesArray)")
        for device in devicesArray {
            //print(device)
            if device.contains("battery_level"){
                iPhoneBatteryLevelEntityID = device
            }
            if device.contains("switch"){
                plugStateEntityID = device
            }
        }
        if !checked {
            if iPhoneBatteryLevelEntityID == " " {
                devicesArray = []
                let alert = UIAlertController(title: "Please set your device preferences in settings!", message:"Please set your device preferences in settings!" , preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "batteryMonitorToSettings", sender: self)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                checked = true
            }
        }
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
    
    
    //makes a call to the api for plug state
    @objc func checkPlugState(plugDevice: String) {
        deviceStateManager.fetchPlugState(urlEndPoint: plugDevice)
        
    }
    
    
    //makes a call to api for battery level or state
    @objc func checkBatteryLevel(batteryDevice: String) {
        deviceStateManager.fetchDeviceData(deviceName: batteryDevice)
        // print(iPhoneBatteryStateEntityID)
        
    }
    
    
    //function to check the current devices
    func updateDevicesArray(newDevicesArray: [String]) {
        devicesArraySemaphore.wait()
        self.devicesArray = newDevicesArray
        devicesArraySemaphore.signal()
    }
    
    
    func scheduleFetchData(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] timer in
            self!.fetchData()
        }
    }
    
    
    func stopFetchingData() {
        timer?.invalidate()
    }
    
    
    func fetchData() {
        self.checkBatteryLevel(batteryDevice: self.iPhoneBatteryLevelEntityID)
        self.checkPlugState(plugDevice: self.plugStateEntityID)
        self.checkBatteryLevel(batteryDevice: self.iPhoneBatteryStateEntityID)
        self.scheduleFetchData()
    }
    
    
    // change the plug icon color on the viewcontroller UI to match its state
    func updatePlugColour(state: String) {
        //print(state)
        if state == K.off {
            powerPlugIcon.tintColor = UIColor(named: K.ColourAssets.plugIconColourOff)
            plugColour = K.off
        }else {
            powerPlugIcon.tintColor = UIColor(named: K.ColourAssets.plugIconColourOn)
            plugColour = K.on
        }
    }
    
    //func checks if the slider is moved and updates the lowestBatteryCharge Level to the users desired level
    @IBAction func sliderMoved(_ sender: UISlider) {
        setBatteryLevel.textColor = UIColor(named: K.ColourAssets.numberColour)
        button.isSelected = false
        button.setTitle("Set", for: .normal)
        lowestBatteryChargeLevel = Int(sender.value)
        print("The LowestBatteryLevel is set at \(lowestBatteryChargeLevel)")
        // make the set level into text
        setBatteryLevel.text = String(format: "%d",  lowestBatteryChargeLevel)
        currentBatteryLevel = Int(batteryPercentageLabel.text ?? "0")!
    }
    
    // updates the colour of the text for the users battery level and changes thetext on the button to done
    @IBAction func buttonPressed(_ sender: UIButton) {
        // change button text to set level
        sender.isSelected = true
        setBatteryLevel.textColor = UIColor(named: K.ColourAssets.affirmAction)
        sender.setTitle("Done", for: .normal)
        stopFetchingData()
        scheduleFetchData()
    }
    
    
    
    // performs the Firebase Auth logout function to sign the user out of the application
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            //clears the device array on log out
            devicesArray = []
            HomeManager.shared.clearCache()
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
    /**
     This method updates the UI with the latest device data and manages the battery states.
     
     - Parameters:
     - deviceManager: The instance of the DeviceManager class that manages the devices.
     - device: The DeviceModel object representing the device that was updated.
     
     - Returns: Void.
     */
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel) -> Void {
        
        // Handle data for multiple device calls from the DeviceManager.
        DispatchQueue.main.async { [self] in
            
            // Check if the updated device is the iPhone battery level.
            if device.id == iPhoneBatteryLevelEntityID {
                
                // Change battery percentage to current battery percentage state.
                self.batteryPercentageLabel.text = device.state
                currentBatteryLevel = Int(device.state) ?? Int(batteryPercentageLabel.text!)!
                
                // Changes the battery level label to the friendly name of the device with white space to centralize the string.
                let phoneName = AppUtility.shortenString(string: device.name, maxLength: 19, minLength: 17)
                self.iPhoneBatteryDeviceName?.text = phoneName
            }
            
            // Check if the updated device is the plug state.
            if device.id == plugStateEntityID {
                
                // Set the plug name label to the connected device name.
                plugName.text = "\(device.name) plug connected"
                
                // If the current battery level is less than or equal to the lowest battery charge level or the battery is full, manage the battery state.
                if currentBatteryLevel <= lowestBatteryChargeLevel || currentBatteryLevel == 100  {
                    
                    // Check the time since the last plug state check.
                    let timeSinceLastCheck = Date().timeIntervalSince(self.lastPlugStateCheckTime)
                    
                    // If more than 30 seconds have passed since the last check, manage the battery state.
                    if timeSinceLastCheck > 30 {
                        lastPlugStateCheckTime = Date()
                        print(lastPlugStateCheckTime)
                        plugColour = self.deviceStateManager.manageBattery(device: device, lowestBatteryChargeLevel: lowestBatteryChargeLevel, currentBatteryLevel: currentBatteryLevel, plugName: plugStateEntityID)
                    }
                }
                
                // Update the plug color based on the device state.
                updatePlugColour(state: device.state)
            }
            
            // Check if the updated device is the iPhone battery state.
            if device.id == iPhoneBatteryStateEntityID {
                
                // If the device is not charging and the plug is off, set an alert to charge.
                if device.state == "Not Charging" && plugColour == K.off {
                    print("\(device.name) is \(device.state)")
                } else {
                    
                    // Check the device state and manage the battery state accordingly.
                    switch device.state {
                    case "Charging":
                        print("\(device.name) is charging")
                        break
                    case "Not Charging":
                        //print("\(device.name) is not charging but the plug is on")
                        break
                    case "Full":
                        print("\(device.name) is full and charging should be stopped")
                        plugColour = self.deviceStateManager.manageBattery(device: device, lowestBatteryChargeLevel: lowestBatteryChargeLevel, currentBatteryLevel: currentBatteryLevel, plugName: plugStateEntityID)
                        break
                    default:
                        print("\(device.name) has an unknown issue, check state in home assistant")
                        break
                    }
                }
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


