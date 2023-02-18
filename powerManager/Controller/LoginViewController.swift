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
    var failedLoginAttempts = 0 // keep track of the number of failed login attempts
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // login action, checks the users data is valid and if so proceeds to log in and segues to the BatteryMonitorViewController
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
                   Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                       if let e = error {
                           // increment failed login attempts and check if it exceeds the threshold
                           self?.failedLoginAttempts += 1
                           if self?.failedLoginAttempts == 3 {
                               self?.showResetPasswordPrompt()
                           } else {
                               // notify the user of the error followed by a dismissal of OK
                               let alert = UIAlertController(title: "Please Check!", message: e.localizedDescription, preferredStyle: .alert)
                               let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                               alert.addAction(okAction)
                               self!.present(alert, animated: true, completion: nil)
                           }
                       } else {
                           // reset failed login attempts counter and segue to the BatteryMonitorViewController
                           self?.failedLoginAttempts = 0
                           self!.performSegue(withIdentifier: K.loginToBatteryMonitor, sender: self)
                       }
                   }
               }
    }
    
    // shows a prompt to reset the user's password
        func showResetPasswordPrompt() {
            let alert = UIAlertController(title: "Password Reset", message: "You have entered an incorrect password 3 times. Would you like to reset your password?", preferredStyle: .alert)
            let resetAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] action in
                self?.resetPassword()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(resetAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    
    // reset password option with alerts if the user forgets their password 3 times
    func resetPassword() {
            if let email = emailTextField.text, !email.isEmpty {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        // notify the user of the error
                        let alert = UIAlertController(title: "Please Check!", message: error.localizedDescription, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        // notify the user that a password reset email has been sent
                        let alert = UIAlertController(title: "Password reset email sent", message: "Please check your email inbox for instructions on how to reset your password.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                // notify the user that they need to enter their email address
                let alert = UIAlertController(title: "Please Check!", message: "Please enter your email address.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default,handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    
    // reset password with email field for user initiated password reset option
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
