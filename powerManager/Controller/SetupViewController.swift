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
    
    func updateDNOAndVoltageData(dno: String, voltage: Double, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let energyDataRef = db.collection("energyReadCollection").document("energydatadocument")
        
        energyDataRef.updateData([
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
        

    @IBAction func setButtonPressed(_ sender: Any) {
        
        
    }
    

}
