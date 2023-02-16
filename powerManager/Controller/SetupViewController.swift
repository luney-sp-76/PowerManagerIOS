//
//  SetUpViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 16/02/2023.
//

import UIKit
import FirebaseFirestore

class SetUpViewController: UIViewController , UITextFieldDelegate {
    
    
    
    @IBOutlet weak var dnoTextField: UITextField!
    @IBOutlet weak var voltageTextField: UITextField!
    @IBOutlet weak var homeAssistantUrlTextField: UITextField!
    @IBOutlet weak var HomeAssistantTokenTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the UiTextFIeldDelegate as self for paste from clipboard
        dnoTextField.delegate = self
        voltageTextField.delegate = self
        homeAssistantUrlTextField.delegate = self
        HomeAssistantTokenTextField.delegate = self

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            // Check if the user is pasting into the text field
            if UIPasteboard.general.string != nil {
                // Get the text that the user is pasting
                let pasteString = UIPasteboard.general.string!
                
                // Replace the selected text range with the pasted text
                let currentText = textField.text ?? ""
                let updatedText = (currentText as NSString).replacingCharacters(in: range, with: pasteString)
                textField.text = updatedText
                
                // Prevent the original paste action from happening
                return false
            }
            
            // Allow the text to be changed as normal
            return true
        }
   
 
    @IBAction func setButtonPressed(_ sender: Any) {
        
        
    }
    

}
