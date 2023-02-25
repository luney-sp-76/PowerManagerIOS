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

class SecurityViewController: UIViewController , UITextFieldDelegate {
    
    
    let secureData = SecuredDataFetcher()
    
 
    @IBOutlet weak var homeAssistantUrlTextField: UITextField!
    @IBOutlet weak var HomeAssistantTokenTextField: UITextField!
    
    @IBOutlet weak var saltedPasswordTextField: UITextField!
    
    var lastPastedTextField: UITextField?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the UiTextFIeldDelegate as self for paste from clipboard
        homeAssistantUrlTextField.delegate = self
        HomeAssistantTokenTextField.delegate = self
        
    }
    
    //lock the screen orientation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    //removes the contstraint on orientation lock from portrait back to all
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
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

    
    //This function generates a 256-bit symmetric key using bcrypt based on the user's password, salt, and the number of iterations. The plaintext data (i.e., the concatenated homeAssistantUrl and longLivedToken) is then encrypted using the key and a randomly generated nonce using the AES.GCM algorithm. The encrypted data, nonce, and salt are then stored in the securedData collection in Firestore.
    func updateSecureData(homeAssistantUrl: String, longLivedToken: String, password: String, completion: @escaping (Error?) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email, !homeAssistantUrl.isEmpty, !longLivedToken.isEmpty, !password.isEmpty else {
            return
        }
        let password = K.decrypt

        // Check if homeAssistantUrl is a valid URL
        guard let _ = URL(string: homeAssistantUrl) else {
            print("url not accepted")
            // handle error
            return
        }

        //long lived token must be over 40 characters long
        if longLivedToken.count < 40 {
            print("token not accepted")
            // handle error
            return
        }
        
        // Generate a symmetric key using bcrypt
        let salt = UUID().uuidString
        let key = secureData.generateBcryptKey(from: password, salt: Data(salt.utf8))

        // Create a 12-byte nonce
        let nonce = AES.GCM.Nonce()

        // Convert the plaintext data to bytes
        let plaintext = "\(homeAssistantUrl),\(longLivedToken)".data(using: .utf8)!

        // Encrypt the plaintext using the key and nonce
        let symmetricKey = SymmetricKey(data: key)
        do {
            // Encrypt the plaintext using the key and nonce
            let sealedBox = try AES.GCM.seal(plaintext, using: symmetricKey, nonce: nonce)

            // Store the encrypted data, nonce, and salt in your database
            let db = Firestore.firestore()
            let securedDataRef = db.collection("securedData").document(userEmail)
            securedDataRef.setData([
                "user": userEmail,
                "encryptedData": sealedBox.ciphertext,
                "nonce": Data(nonce),
                "salt": salt
            ]) { error in
                if let error = error {
                    print("error uploading data to database")
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        } catch {
            print("Error encrypting the plaintext: \(error)")
            // handle error
        }
    }
    
    
    
    //This code checks if dno is zero using the == operator, and if it is, it sets dnoWithDefault to 23 using the ternary operator ? :. If dno is not zero, dnoWithDefault is set to the value of dno. CURRENTLY SETS PASSWORD TO Hardcoded value as it would require a seperate server or expensive management to hold the password in a keyvault.
    @IBAction func setButtonPressed(_ sender: Any) {
 
        let homeAssistantUrl = homeAssistantUrlTextField.text
        let longLivedToken = HomeAssistantTokenTextField.text
        let password = saltedPasswordTextField.text
        // Check if either the dno and voltage fields are both completed or the homeassistant URL and token fields are both completed
        guard (homeAssistantUrl != nil && longLivedToken != nil && password != nil && !homeAssistantUrl!.isEmpty && !longLivedToken!.isEmpty && !password!.isEmpty)
        else {
            // handle error
            return
        }
        
        
        if let url = homeAssistantUrl, let token = longLivedToken, let password = password {
            updateSecureData(homeAssistantUrl: url, longLivedToken: token, password: password) { error in
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
