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
    
    
    
    @IBOutlet weak var dnoTextField: UITextField!
    @IBOutlet weak var voltageTextField: UITextField!
    @IBOutlet weak var homeAssistantUrlTextField: UITextField!
    @IBOutlet weak var HomeAssistantTokenTextField: UITextField!
    var lastPastedTextField: UITextField?
    var dnoText: String = "23"
    var voltageText: String = " "
    var homeAssistantURl: String = " "
    var longLivedToken: String = " "
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the UiTextFIeldDelegate as self for paste from clipboard
        //dnoTextField.delegate = self
        //voltageTextField.delegate = self
        homeAssistantUrlTextField.delegate = self
        HomeAssistantTokenTextField.delegate = self

    }
    
    // function otcheck if the textfield is empty and allow the text to be pasted from clip board
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let pastedString = UIPasteboard.general.string {
                // If this is the first edit event after a paste, clear the text field
                if textField == lastPastedTextField {
                    textField.text = ""
                }
                // Otherwise, record the text field as the last one pasted into
                else {
                    lastPastedTextField = textField
                }
                
                // Append the pasted text to the text field
                let currentText = textField.text ?? ""
                let updatedText = (currentText as NSString).replacingCharacters(in: range, with: pastedString)
                textField.text = updatedText
                
                // Prevent the original paste action from happening
                return false
            }
            
            // If the user is not pasting, allow the text to be changed as normal
            return true
        }
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            // Reset the "last pasted" text field if the user starts editing a different field
            lastPastedTextField = nil
            return true
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

    //This code checks if dno is zero using the == operator, and if it is, it sets dnoWithDefault to 23 using the ternary operator ? :. If dno is not zero, dnoWithDefault is set to the value of dno.
    @IBAction func setButtonPressed(_ sender: Any) {
        guard let dnoText = dnoTextField.text, let dno = Int(dnoText), !dnoText.isEmpty,
              let voltageText = voltageTextField.text?.uppercased(), !voltageText.isEmpty
        else {
            // handle error
            return
        }
        
        let dnoWithDefault = dno == 0 ? 23 : dno
        
        if !dnoText.isEmpty && !voltageText.isEmpty {
            updateDNOAndVoltageData(dno: dnoWithDefault, voltage: voltageText) { error in
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
