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
    
    
    //uses the input from the email and password fields to check if the user is new or registered and if the password and email are valid
    //If all passes then the user segues to the BatteryMonitorViewController or else is given appropriate prompts
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
    


