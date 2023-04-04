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
    

    /**
    This function updates a Firestore document that contains encrypted sensitive information related to a user. The information is encrypted using the RNCryptor encryption library and stored in the Firestore database.

    The function takes in three parameters:

    homeAssistantUrl: A string that represents the URL of the user's Home Assistant instance.
    longLivedToken: A string that represents the long-lived access token that the user has generated in their Home Assistant instance. This token is used to authenticate the user's requests to the instance.
    completion: A closure that is called when the update operation completes, whether it succeeds or fails. The closure takes in an optional Error parameter, which will be nil if the operation succeeds and will contain an error object if the operation fails.
    The function first checks that the current user's email is not nil, and that both the homeAssistantUrl and longLivedToken parameters are not empty. If any of these conditions are not met, the function returns early and does not perform any database updates.

    Next, the function checks that the length of the longLivedToken parameter is at least 40 characters. If it is not, the function prints an error message and returns early.

    The function then converts the homeAssistantUrl and longLivedToken parameters into a plaintext string, concatenates them with a comma separator, and encodes the resulting string as UTF-8 data. This plaintext data is then encrypted using the RNCryptor library.

    The encrypted data is then uploaded to the Firestore database as a new document under the "securedData" collection, with the user's email as the document ID. The document contains the encrypted data and the user's email.

    If there are any errors during the upload process, the function calls the completion closure with the error. Otherwise, the function calls the completion closure with a nil error to indicate that the update was successful.

    Note that the function assumes that the RNCryptor password is stored securely in the app and accessible through the K.decrypt constant. It also assumes that the Firestore database is configured correctly and that the current user is authenticated with Firebase Auth.
    */
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

    
    
    /**
    This function is called when the user presses the "set" button in the app's settings screen. It updates the user's Home Assistant URL and long-lived access token in the Firestore database by calling the updateSecureData() function.

    The function first retrieves the user's input for the Home Assistant URL and long-lived access token from the corresponding text fields in the app. It then retrieves the RNCryptor password from the K.decrypt constant, which is currently hardcoded in the app.

    If both the Home Assistant URL and long-lived access token fields are completed and the RNCryptor password is not empty, the function calls the updateSecureData() function with the retrieved values. If any of these conditions are not met, the function returns early and does not perform any updates.

    The updateSecureData() function encrypts the Home Assistant URL and long-lived access token using RNCryptor and stores the encrypted data in Firestore under the user's email address. The RNCryptor password is used to encrypt and decrypt the data.

    Note that the current implementation uses a hardcoded RNCryptor password, as storing the password securely in a key vault or server would require additional infrastructure and management. This may pose a security risk and should be addressed in future iterations of the app.

    If the updateSecureData() function succeeds, the "set" button title is updated to indicate success and the text fields are cleared. If it fails, the "set" button title is updated to indicate failure and an error message is printed to the console.

    Note that the function assumes that the text fields are non-nil and non-empty, and that the updateSecureData() function is correctly implemented and configured with Firestore and RNCryptor.
    */
    @IBAction func setButtonPressed(_ sender: UIButton) {
 
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
                    sender.setTitle("That didn't work, log out and try again", for: .normal)
                    print("Error updating data: \(error.localizedDescription)")
                } else {
                    // data updated successfully
                    sender.setTitle("Data updated successfully", for: .normal)
                    self.homeAssistantUrlTextField.text =  " "
                    self.HomeAssistantTokenTextField.text = " "
                    print("Data updated successfully")
                }
            }
        }
    }

    
}

