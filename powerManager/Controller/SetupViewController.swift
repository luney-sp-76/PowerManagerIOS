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
    //we first calculate the length of the new text after pasting by adding the length of the current text and the pasted string, and then subtracting the length of the range being replaced. We then check if this new length is within the maximum length of the text field (textField.maxLength). If it is, we replace the range with the pasted string. Otherwise, we do nothing and return false to prevent the paste action from happening.
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
            
            // Allow pasting only for the desired text fields
            if textField == homeAssistantUrlTextField {
                let maxLength = 90
                let currentText = textField.text ?? ""
                let newTextLength = currentText.count + pastedString.count - range.length
                if newTextLength <= maxLength {
                    let updatedText = (currentText as NSString).replacingCharacters(in: range, with: pastedString)
                    textField.text = updatedText
                }
            } else if textField == HomeAssistantTokenTextField {
                let updatedText = (textField.text! as NSString).replacingCharacters(in: range, with: pastedString)
                textField.text = updatedText
            }
            
            // Prevent the original paste action from happening
            return false
        }
        
        // If the user is not pasting, allow the text to be changed as normal
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
    
    func updateSecureData(homeAssistantUrl: String, longLivedToken: String, completion: @escaping (Error?) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email, !homeAssistantUrl.isEmpty, !longLivedToken.isEmpty else {
            return
        }
        // Check if homeAssistantUrl is a valid URL
        guard let _ = URL(string: homeAssistantUrl) else {
            // handle error
            return
        }
        //long lived token must be over 40 characters long
        if longLivedToken.count < 40 {
            // handle error
            return
        }
        
        // Hash the homeAssistantUrl and longLivedToken using SHA-256 algorithm
        let hashedUrl = SHA256Crypto.hashString(homeAssistantUrl)
        let hashedToken = SHA256Crypto.hashString(longLivedToken)
        
        let db = Firestore.firestore()
        let securedDataRef = db.collection("securedData").document(userEmail)
        securedDataRef.setData([
            "user": userEmail,
            "hashedUrl": hashedUrl,
            "hashedToken": hashedToken
        ]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    
    //This code checks if dno is zero using the == operator, and if it is, it sets dnoWithDefault to 23 using the ternary operator ? :. If dno is not zero, dnoWithDefault is set to the value of dno.
    @IBAction func setButtonPressed(_ sender: Any) {
        let dnoText = dnoTextField.text
        let voltageText = voltageTextField.text?.uppercased()
        let homeAssistantUrl = homeAssistantUrlTextField.text
        let longLivedToken = HomeAssistantTokenTextField.text

        // Check if either the dno and voltage fields are both completed or the homeassistant URL and token fields are both completed
        guard (dnoText != nil && voltageText != nil && !dnoText!.isEmpty && !voltageText!.isEmpty) ||
                  (homeAssistantUrl != nil && longLivedToken != nil && !homeAssistantUrl!.isEmpty && !longLivedToken!.isEmpty)
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

        if let url = homeAssistantUrl, let token = longLivedToken {
            // Check if homeAssistantUrl is a valid URL
            guard let _ = URL(string: url) else {
                // handle error
                return
            }

            //long lived token must be 40 characters long
            if token.count != 40 {
                // handle error
                return
            }

         

            updateSecureData(homeAssistantUrl: homeAssistantUrl!, longLivedToken: longLivedToken!) { error in
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
