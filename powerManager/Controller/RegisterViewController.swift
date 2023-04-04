//
//  RegisterViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 15/01/2023.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    /**
     
      Registers a new user with Firebase authentication using the provided email and password.
      If the registration is successful, performs a segue to the BatteryMonitorViewController.
     If there is an error during the registration process, displays an alert controller with the error message.
      - Parameters:
        - sender: The UIButton that triggered the function.
      - Returns:
        - None.
     
    */
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error {
                    //notify users
                    let alert = UIAlertController(title: "Please Check!", message: e.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self!.present(alert, animated: true, completion: nil)
                } else {
                    self!.performSegue(withIdentifier: K.registerToBatteryMonitor, sender: self)
                }
                
            }
            
        }
    }
}
    


