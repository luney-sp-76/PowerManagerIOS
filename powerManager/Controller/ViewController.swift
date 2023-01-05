//
//  ViewController.swift
//  powerManager
//
//  Created by Paul on 29/12/2022.
//

import UIKit

class ViewController: UIViewController {
    
    var deviceManager = DeviceManager()
    var plugControl = PlugControl()
    var batteryPercentage = 21
    
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    @IBOutlet weak var setBatteryLevel: UILabel!
    @IBOutlet weak var button: UIButton!
    var currentBatteryLevel = 100
    var lowestBatteryChargeLevel = 21
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceManager.delegate = self
        deviceManager.fetchDeviceData(deviceName: "sensor.iphone_8_number_1", urlEndPoint: "_battery_level")
        
        
    }
    
    @objc func battery(level: String){
        print("hi its the battery timer")
        
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
        //check battery level
        //check plug state
        //take action based on if the battery is 100% turn plug off. If battery is above the set Level batteryPercentage
        //turn plug off. Otherwise turn plug on and start checking the database for updates and or api for updates
    }
    
}

//MARK: - DeviceManagerDelegate

extension ViewController: DeviceManagerDelegate {
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel) {
        //change battery percentage to current battery percentage
        
        DispatchQueue.main.async { [self] in
           if device.name == "iPhone 8 Number 1 Battery Level"{
                self.batteryPercentageLabel.text = device.state
            }
            deviceManager.fetchPlugState(urlEndPoint: "switch.0x0015bc002f00edf3")
            if currentBatteryLevel >= 100 && device.name == "develco" && device.state == "on" {
                self.plugControl.fetchPlugData(deviceName: "switch.0x0015bc002f00edf3/", urlEndPoint: "turn_off")
               
                
            } else if currentBatteryLevel <= lowestBatteryChargeLevel && device.name == "develco" && device.state == "off"{
                plugControl.fetchPlugData(deviceName: "switch.0x0015bc002f00edf3/", urlEndPoint: "turn_on")
            }
        }
        sleep(UInt32(30.00))
        let timer = Timer.scheduledTimer(timeInterval: 6000.00, target: self, selector: #selector(self.battery), userInfo:deviceManager.fetchDeviceData(deviceName: "sensor.iphone_8_number_1", urlEndPoint: "_battery_level") , repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
}

//MARK: - PlugControlDelegate

extension ViewController: PlugManagerDelegate {
    func didUpdateDevice(_ PlugManager: PlugControl){
        print("updated")
    }
    
    func didFailWithError(_ error: Error){
        print(error)
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

