//
//  ViewController.swift
//  powerManager
//
//  Created by Paul on 29/12/2022.
//

import UIKit
import FirebaseAuth



class BatteryMonitorViewController: UIViewController {
    
    // initiate DeviceManager
    var deviceStateManager = DeviceManager()
    //initiate PlugControl
    var plugControl = PlugControl()
    //initial HomeManager
    var homeManager = HomeManager()
    // to hold the devies selected in settings
    var devicesArray: [String] = []
    
    var batteryPercentage = 21
    // Declare the delegate property in BatteryMonitorViewController
    var plugColour = "off"
    var iPhoneBatteryLevelEntityID = " "
    var plugStateEntityID = " "
    
    
    
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    @IBOutlet weak var setBatteryLevel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var powerPlugIcon: UIImageView!
    
    var currentBatteryLevel = 100
    var lowestBatteryChargeLevel = 21
    var lastPlugStateCheckTime: Date = Date()
    
    
    
    
    
    
    override func viewDidLoad() {
        print("view is loaded")
        print("devicesArray has \(devicesArray.count) devices")
        title = K.appName
        navigationItem.hidesBackButton = true
        deviceStateManager.delegate = self
        for device in devicesArray {
            print(device)
            if device.contains("battery_level"){
                iPhoneBatteryLevelEntityID = device
            }
            if device.contains("switch"){
                plugStateEntityID = device
            }
        }
        if iPhoneBatteryLevelEntityID == " " {
            let alert = UIAlertController(title: "Please set your device preferences in settings!", message:"Please set your device preferences in settings!" , preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "batteryMonitorToSettings", sender: self)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            //batteryManager.delegate = self
            scheduleFetchData()
        }
    }
    
    
    //lock the screen orientation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    @objc func checkPlugState(plugDevice: String) {
        deviceStateManager.fetchPlugState(urlEndPoint: plugDevice)
        
    }
    
    @objc func checkBatteryLevel(batteryDevice: String) {
        deviceStateManager.fetchDeviceData(deviceName: batteryDevice)
        print(iPhoneBatteryLevelEntityID)
        
    }
    
    func scheduleFetchData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            print(self.iPhoneBatteryLevelEntityID)
            self.checkBatteryLevel(batteryDevice: self.iPhoneBatteryLevelEntityID)
            self.checkPlugState(plugDevice: self.plugStateEntityID)
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
            if device.id == iPhoneBatteryLevelEntityID {
                //change battery percentage to current battery percentage state
                self.batteryPercentageLabel.text = device.state
                currentBatteryLevel = Int(device.state) ?? Int(batteryPercentageLabel.text!)!
            }
            if device.id == plugStateEntityID {
                print(device.id)
                V.plugStateEntityID = plugStateEntityID
                if currentBatteryLevel <= lowestBatteryChargeLevel || currentBatteryLevel == 100  {
                    print("THIS SHOULD CALL TO TURN THE PLUG ON OR OFF!!!")
                    
                    plugColour = self.deviceStateManager.manageBattery(device: device, lowestBatteryChargeLevel: lowestBatteryChargeLevel, currentBatteryLevel: currentBatteryLevel, plugName: plugStateEntityID)
                }
                //print("global variable is set as \(V.plugStateEntityID)")
                updatePlugColour(state: device.state)
            }
        }
        
        let timeSinceLastCheck = Date().timeIntervalSince(self.lastPlugStateCheckTime)
        if timeSinceLastCheck > 30 {
            lastPlugStateCheckTime = Date()
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




//        print("data recieved from SettingsViewController")
//        iPhoneBatteryLevelEntityID = battery
//        plugStateEntityID = plug
 

