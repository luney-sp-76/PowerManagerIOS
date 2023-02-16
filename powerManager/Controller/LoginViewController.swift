//
//  LoginViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 09/01/2023.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // login action, checks the users data is valid and if so proceeds to log in and segues to the BatteryMonitorViewController
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error {
                    //notify users
                    let alert = UIAlertController(title: "Please Check!", message: e.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self!.present(alert, animated: true, completion: nil)
                } else {
                    self!.performSegue(withIdentifier: K.loginToBatteryMonitor, sender: self)
                }
                
            }
            
        }
    }
    
    
    // reset password with email field
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        if let email = emailTextField.text, !email.isEmpty {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    //notify users
                    let alert = UIAlertController(title: "Please Check!", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    //notify users
                    let alert = UIAlertController(title: "Password reset email sent", message: "Please check your email inbox for instructions on how to reset your password.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            //notify users
            let alert = UIAlertController(title: "Please Check!", message: "Please enter your email address.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
