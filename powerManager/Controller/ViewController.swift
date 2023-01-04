//
//  ViewController.swift
//  powerManager
//
//  Created by Paul on 29/12/2022.
//

import UIKit

class ViewController: UIViewController {
    
    var deviceManager = DeviceManager()
    var batteryPercentage = 21
   
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    @IBOutlet weak var setBatteryLevel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceManager.delegate = self
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        setBatteryLevel.textColor = UIColor(named: "NumberColor")
        button.isSelected = false
        button.setTitle("Set", for: .normal)
        batteryPercentage = Int(sender.value)
        setBatteryLevel.text = String(format: "%d", batteryPercentage)
        
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        // change button text to set level
        sender.isSelected = true
        setBatteryLevel.textColor = UIColor(named: "AffirmAction")
        sender.setTitle("Done", for: .normal)
        deviceManager.fetchDeviceData(deviceName: "iphone_8_number_1", urlEndPoint: "_battery_level")
       
        
        
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
        //call the api via DeviceManager
        DispatchQueue.main.async {
            self.batteryPercentageLabel.text = device.state
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
}

