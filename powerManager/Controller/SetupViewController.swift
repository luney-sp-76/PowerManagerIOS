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
    
    

    
    /**
    This function updates the user's DNO and voltage settings in the Firestore database. It takes in two parameters: an integer dno that represents the user's DNO value, and a string voltage that represents the user's voltage value. The function also takes in a completion closure that is used to handle any errors that occur during the update process.

    The function first retrieves the Firestore database reference using the Firestore object. It then checks if the current user's email is not nil. If it is not nil, the function retrieves a reference to the user's energy read document in the Firestore database.

    The function then updates the energy read document with the user's DNO and voltage values, as well as the user's email. If the update operation succeeds, the function calls the completion closure with a nil error. If it fails, the function calls the completion closure with the error.

    Note that this function assumes that the user is authenticated and that the Firestore database is correctly set up with the appropriate collections and fields. Any changes to these assumptions may require modifications to this function.

    Parameters:

    - dno: An integer that represents the user's DNO value.
    - voltage: A string that represents the user's voltage value.
    - completion: A closure that is called when the update operation is completed.
     
    - The closure takes in an optional Error object that represents any errors that occurred during the update process.
    Note that the completion closure is responsible for handling any errors that occur during the update process. The closure should check if the error object is nil before performing any further actions.
    */
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
    
    
    
    /**
    This function is called when the user presses the "set" button in the app's settings screen. It updates the DNO and voltage settings in the Firestore database by calling the updateDNOAndVoltageData() function.

    The function first retrieves the user's input for the DNO and voltage fields from the corresponding text fields in the app. It then checks if both fields are non-nil and non-empty, and returns early if either field is missing.

    If both fields are present, the function attempts to parse the DNO field as an integer and the voltage field as a string. If parsing is successful, the function checks if the DNO is zero using the == operator. If it is, the function sets a default value of 23 for the DNO using the ternary operator ? :. If the DNO is not zero, the function uses its parsed value.

    The function then calls the updateDNOAndVoltageData() function with the parsed DNO and voltage values. If the update operation succeeds, the "set" button title is updated to indicate success. If it fails, the "set" button title is updated to indicate failure and an error message is printed to the console.

    Note that the current implementation uses a hardcoded password in the updateDNOAndVoltageData() function, as storing the password securely in a key vault or server would require additional infrastructure and management. This may pose a security risk and should be addressed in future iterations of the app.

    The function also assumes that the DNO field can be parsed as an integer and that the voltage field is a non-empty string. Any changes to these assumptions may require modifications to this function.

    Parameters:
    - sender: A UIButton object that represents the "set" button in the app's settings screen.
     
    Note that this function assumes that the updateDNOAndVoltageData() function is correctly implemented and configured with Firestore.
    */
    @IBAction func setButtonPressed(_ sender: UIButton) {
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
                    // handle error\
                    sender.setTitle("That didn't work, please try again", for: .normal)
                    print("Error updating data: \(error.localizedDescription)")
                } else {
                    // data updated successfully
                    sender.setTitle("Updated successfully", for: .normal)
                    print("Data updated successfully")
                }
            }
        }
    }
        
      

    
}
