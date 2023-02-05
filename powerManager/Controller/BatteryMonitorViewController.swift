//
//  ViewController.swift
//  powerManager
//
//  Created by Paul on 29/12/2022.
//

import UIKit
import FirebaseAuth



class BatteryMonitorViewController: UIViewController {
    
    //ensure the viewDidLoad only happens once on each occasion
    private var viewHasLoaded = false
    // initiate DeviceManager
    var deviceStateManager = DeviceManager()
    //initiate PlugControl
    var plugControl = PlugControl()
    //initial HomeManager
    var homeManager = HomeManager()
    var dataProvider = DataProvider()
    // to hold the devies selected in settings
    var devicesArray: [String] = []
    
    var batteryPercentage = 21
    // Declare the delegate property in BatteryMonitorViewController
    var plugColour = "off"
    var iPhoneBatteryLevelEntityID = " "
    var iPhoneBatteryStateEntityID = " "
    var plugStateEntityID = " "
    var devicesArraySemaphore = DispatchSemaphore(value: 1)

    
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    @IBOutlet weak var setBatteryLevel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var powerPlugIcon: UIImageView!
    
    var currentBatteryLevel = 100
    var lowestBatteryChargeLevel = 0
    var lastPlugStateCheckTime: Date = Date()
    
    
    
    override func viewDidLoad() {
        if !viewHasLoaded {
            viewHasLoaded = true
           // print("view is loaded")
            //print("devicesArray has \(devicesArray.count) devices")
            title = K.appName
            navigationItem.hidesBackButton = true
            deviceStateManager.delegate = self
            checkDataHasLoaded()
        }
        else {
           return
        }
    }
    
    //this function checks if there are a battery_level and switch device in the devices Array
    //it updates the variables for iPhoneBatteryLevelEntityID and  plugStateEntityID with the data from the array
    //if iPhoneBatteryLevelEntityID is not present or has no value the user is prompted to add devices and pointed to the SettigsViewController via the segue
    func checkDataHasLoaded() {
        print("The array of devices chosen in settings is now \(devicesArray)")
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
            devicesArray = []
            let alert = UIAlertController(title: "Please set your device preferences in settings!", message:"Please set your device preferences in settings!" , preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "batteryMonitorToSettings", sender: self)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
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
        print(iPhoneBatteryStateEntityID)
        
    }
    
    
    func updateDevicesArray(newDevicesArray: [String]) {
        devicesArraySemaphore.wait()
        self.devicesArray = newDevicesArray
        devicesArraySemaphore.signal()
    }
    
    
    //managed calls to check the battery level check the plug state in recursive loop
    func scheduleFetchData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            //double check we are now using the updated devices
            self.devicesArraySemaphore.wait()
            let localDevicesArray = self.devicesArray
            self.devicesArraySemaphore.signal()
            
            for device in localDevicesArray {
                if device.contains(K.batteryLevel){
                    self.iPhoneBatteryLevelEntityID = device
                }
                if device.contains(K.switchs){
                    self.plugStateEntityID = device
                }
            }
            print("The current phone is \(self.iPhoneBatteryLevelEntityID)")
            print("The current plug is \(self.plugStateEntityID)")
            self.checkBatteryLevel(batteryDevice: self.iPhoneBatteryLevelEntityID)
            self.checkPlugState(plugDevice: self.plugStateEntityID)
            self.checkBatteryLevel(batteryDevice: self.iPhoneBatteryStateEntityID)
            self.scheduleFetchData()
        }
    }
    
    // change the plug icon color on the viewcontroller UI to match its state
    func updatePlugColour(state: String) {
        //print(state)
        if state == K.off {
            powerPlugIcon.tintColor = UIColor(named: K.ColourAssets.plugIconColourOff)
        }else {
            powerPlugIcon.tintColor = UIColor(named: K.ColourAssets.plugIconColourOn)
        }
    }
    
    
    //func checks if the slider is moved and updates the lowestBatteryCharge Level to the users desired level
    @IBAction func sliderMoved(_ sender: UISlider) {
        setBatteryLevel.textColor = UIColor(named: K.ColourAssets.numberColour)
        button.isSelected = false
        button.setTitle("Set", for: .normal)
        lowestBatteryChargeLevel = Int(sender.value)
        //set a public variable of the users choice of batterylevel to access outside of the viewcontroller
       // V.usersSetBatteryLevel =  lowestBatteryChargeLevel
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
        scheduleFetchData()
    }
    
    
    
    // performs the Firebase Auth logout function to sign the user out of the application
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            //clears the device array on log out
            devicesArray = []
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
        //update firebase
        //dataProvider.transferData()
        DispatchQueue.main.async { [self] in
            if device.id == iPhoneBatteryLevelEntityID {
                //change battery percentage to current battery percentage state
                self.batteryPercentageLabel.text = device.state
                currentBatteryLevel = Int(device.state) ?? Int(batteryPercentageLabel.text!)!
            }
            if device.id == plugStateEntityID {
                
                if currentBatteryLevel <= lowestBatteryChargeLevel || currentBatteryLevel == 100  {
                  
                    plugColour = self.deviceStateManager.manageBattery(device: device, lowestBatteryChargeLevel: lowestBatteryChargeLevel, currentBatteryLevel: currentBatteryLevel, plugName: plugStateEntityID)
                }
                
                updatePlugColour(state: device.state)
            }
            if device.id == iPhoneBatteryStateEntityID {
                //states not charging
                //charging
                print(device.name)
                //set an alert to charge if the device is showing as not charging
                if device.state == "Not Charging"{
                    print(device.state)
                }
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


