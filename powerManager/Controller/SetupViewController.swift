//
//  SetUpViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 16/02/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class SetUpViewController: UIViewController , UITextFieldDelegate {
    
    
    let secureData = SecuredDataFetcher()
    
    @IBOutlet weak var dnoTextField: UITextField!
    @IBOutlet weak var voltageTextField: UITextField!
 

    override func viewDidLoad() {
        super.viewDidLoad()
        //set the UiTextFIeldDelegate as self for paste from clipboard
       dnoTextField.delegate = self
       voltageTextField.delegate = self
        let securityButton = UIBarButtonItem(title: "Security", style: .plain, target: self, action: #selector(self.securityButtonTapped))
                navigationItem.rightBarButtonItem = securityButton
        title = "Set Up"
        
    }
    //lock the screen orientation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.all)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
   
    
    @objc func securityButtonTapped() {
           // Handle setup button tap here
           // For example, perform a segue to the setup view controller
        performSegue(withIdentifier: K.setUpToSecurity, sender: self)
       }
    
  
    
    //removes the contstraint on orientation lock from portrait back to all
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    

    
    //this function sets the data as
    func updateDNOAndVoltageData(dno: Int, voltage: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        if let userEmail = Auth.auth().currentUser?.email {
            let energyDataRef = db.collection("energyReadCollection").document(userEmail)
            energyDataRef.setData([
                "user": userEmail,
                "dno": dno,
                "voltage": voltage
            ]) { error in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    
    
    //This code checks if dno is zero using the == operator, and if it is, it sets dnoWithDefault to 23 using the ternary operator ? :. If dno is not zero, dnoWithDefault is set to the value of dno. CURRENTLY SETS PASSWORD TO Hardcoded value as it would require a seperate server or expensive management to hold the password in a keyvault.
    @IBAction func setButtonPressed(_ sender: Any) {
        let dnoText = dnoTextField.text
        let voltageText = voltageTextField.text?.uppercased()
        // Check if either the dno and voltage fields are both completed or the homeassistant URL and token fields are both completed
        guard (dnoText != nil && voltageText != nil && !dnoText!.isEmpty && !voltageText!.isEmpty)
        else {
            // handle error
            return
        }
        
        if let dno = Int(dnoText!), let voltage = voltageText {
            //default the dno to 23 if zero is entered
            let dnoWithDefault = dno == 0 ? 23 : dno
            
            updateDNOAndVoltageData(dno: dnoWithDefault, voltage: voltage) { error in
                if let error = error {
                    // handle error
                    print("Error updating data: \(error.localizedDescription)")
                } else {
                    // data updated successfully
                    print("Data updated successfully")
                }
            }
        }
    }
        
      

    
}
