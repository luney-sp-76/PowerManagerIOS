//
//  SecurityViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 16/02/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CryptoKit
import CommonCrypto
import RNCryptor


protocol CustomTextFieldDelegate: AnyObject {
    func getLastPastedTextField() -> UITextField?
    func setLastPastedTextField(_ textField: UITextField)
}
//the tag property for each text field is declared in the viewDidLoad method. Then, in the CustomTextField class, the direct reference to homeAssistantUrlTextField and HomeAssistantTokenTextField is replaced with the corresponding tag values to determine which text field is being referred to.
class CustomTextField: UITextField {
    weak var customDelegate: CustomTextFieldDelegate?
    
    override func paste(_ sender: Any?) {
        if let pastedString = UIPasteboard.general.string {
            if self == customDelegate?.getLastPastedTextField() {
                self.text = ""
            } else {
                customDelegate?.setLastPastedTextField(self)
            }
            
            if self.tag == 1 { // homeAssistantUrlTextField
                let maxLength = 90
                let currentText = self.text ?? ""
                let newTextLength = currentText.count + pastedString.count
                
                if newTextLength <= maxLength {
                    self.text = currentText + pastedString
                }
            } else if self.tag == 2 { // HomeAssistantTokenTextField
                self.text = (self.text! + pastedString)
            }
        }
    }
}


class SecurityViewController: UIViewController , UITextFieldDelegate, CustomTextFieldDelegate {
    
    let secureData = SecuredDataFetcher()
    
    var lastPastedTextField: UITextField?
    
   
    
    func getLastPastedTextField() -> UITextField? {
            return lastPastedTextField
        }
    func setLastPastedTextField(_ textField: UITextField) {
           lastPastedTextField = textField
       }
 
    @IBOutlet weak var homeAssistantUrlTextField: CustomTextField!
    @IBOutlet weak var HomeAssistantTokenTextField: CustomTextField!
    
    @IBOutlet weak var saltedPasswordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the CustomTextFieldDelegate as self for paste from clipboard
           // homeAssistantUrlTextField = CustomTextField()
            homeAssistantUrlTextField.customDelegate = self
            homeAssistantUrlTextField.tag = 1
            //HomeAssistantTokenTextField = CustomTextField()
            HomeAssistantTokenTextField.customDelegate = self
            HomeAssistantTokenTextField.tag = 2
        // Set the UITextFieldDelegate for paste from clipboard
             homeAssistantUrlTextField.delegate = self
             HomeAssistantTokenTextField.delegate = self
          
        title = "Security"
        
    }
    

    //This function generates a 256-bit symmetric key using bcrypt based on the user's password, salt, and the number of iterations. The plaintext data (i.e., the concatenated homeAssistantUrl and longLivedToken) is then encrypted using the key and a randomly generated nonce using the AES.GCM algorithm. The encrypted data, nonce, and salt are then stored in the securedData collection in Firestore.
    func updateSecureData(homeAssistantUrl: String, longLivedToken: String, completion: @escaping (Error?) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email, !homeAssistantUrl.isEmpty, !longLivedToken.isEmpty else {
            return
        }
        let password = K.decrypt

        //long lived token must be over 40 characters long
        if longLivedToken.count < 40 {
            print("token not accepted")
            // handle error
            return
        }

        // Convert the plaintext data to bytes
        let plaintext = "\(homeAssistantUrl),\(longLivedToken)".data(using: .utf8)!
        print(plaintext.count)

        // Encrypt the plaintext using RNCryptor
            let encryptedData = RNCryptor.encrypt(data: plaintext, withPassword: password)
            let db = Firestore.firestore()
            let securedDataRef = db.collection("securedData").document(userEmail)
            securedDataRef.setData([
                "user": userEmail,
                "encryptedData": encryptedData,
            ]) { error in
                if let error = error {
                    print("error uploading data to database")
                    completion(error)
                } else {
                    completion(nil)
                }
            }
    }

    
    
    // CURRENTLY SETS PASSWORD TO Hardcoded value as it would require a seperate server or expensive management to hold the password in a keyvault.
    @IBAction func setButtonPressed(_ sender: Any) {
 
        let homeAssistantUrl = homeAssistantUrlTextField.text
        let longLivedToken = HomeAssistantTokenTextField.text
        let password = K.decrypt
        // Check if the homeassistant URL and token fields are both completed
        guard (homeAssistantUrl != nil && longLivedToken != nil && !homeAssistantUrl!.isEmpty && !longLivedToken!.isEmpty && !password.isEmpty)
        else {
            // handle error
            return
        }
        
        
        if let url = homeAssistantUrl, let token = longLivedToken {
            updateSecureData(homeAssistantUrl: url, longLivedToken: token) { error in
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

