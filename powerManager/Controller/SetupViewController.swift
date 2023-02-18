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
    
    
    ///dno text for distribution network operator
    @IBOutlet weak var dnoTextField: UITextField!
    ///voltage text in Caps either LV HV or LV-SUB
    @IBOutlet weak var voltageTextField: UITextField!
    ///potential url capture for the users Homeassistant instance
    @IBOutlet weak var homeAssistantUrlTextField: UITextField!
    ///potential longlived token capture for the users Homeassistant intance
    @IBOutlet weak var HomeAssistantTokenTextField: UITextField!
    //variable to mark user pasted data from clipboard
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
        

    @IBAction func setButtonPressed(_ sender: Any) {
        
        
    }
    

}
