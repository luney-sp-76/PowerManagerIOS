//
//  ViewController.swift
//  powerManager
//
//  Created by Paul on 29/12/2022.
//

import UIKit

class ViewController: UIViewController, DeviceManagerDelegate {
    
    var batteryPercentage = 21
    

    @IBOutlet weak var batteryPercentageLabel: UILabel!
    
    @IBOutlet weak var setBatteryLevel: UILabel!
    
    @IBOutlet weak var button: UIButton!
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
       
        
        //check battery level
        
        //change battery percentage to current battery percentage
        //check plug state
        //take action based on if the battery is 100% turn plug off. If battery is above the set Level batteryPercentage
        //turn plug off. Otherwise turn plug on and start checking the database for updates and or api for updates
        
    }
    
    func didUpdateDevice(_ deviceManager: DeviceManager, device: DeviceModel) {
        let id = device.id
        let name = device.name
        setBatteryLevel.text = device.state
    }
    
    func didFailWithError(error: Error) {
      print(error)
    }
    
    
}

