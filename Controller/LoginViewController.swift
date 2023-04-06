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
    
    /**
     Handles the user's login action.

     - Parameters:
        - sender: The button that triggers the login action.

     - Returns: Void.
     */
    @IBAction func loginPressed(_ sender: UIButton) {
        // Check if the email and password fields are not empty.
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            // Attempt to sign in with the user's email and password.
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                // If there was an error, handle it.
                if let e = error {
                    
                    // increment failed login attempts and check if it exceeds the threshold
                    self?.failedLoginAttempts += 1
                    // If the failed login attempts exceed the threshold, prompt the user to reset their password.
                    if self?.failedLoginAttempts == 3 {
                        self?.showResetPasswordPrompt()
                    } else {
                        
                        // notify the user of the error
                        let alert = UIAlertController(title: "Please Check!", message: e.localizedDescription, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self!.present(alert, animated: true, completion: nil)
                    }
                } else {
                    // reset failed login attempts counter
                    self?.failedLoginAttempts = 0
                    
                    //segue to the BatteryMonitorViewController
                    self!.performSegue(withIdentifier: K.loginToBatteryMonitor, sender: self)
                }
            }
        }
    }
    
    /**
     Shows a prompt to reset the user's password if they have entered an incorrect password three times.
     
     - Returns: Void.
     */
    func showResetPasswordPrompt() {
        // Create an alert with a message asking the user if they want to reset their password.
        let alert = UIAlertController(title: "Password Reset", message: "You have entered an incorrect password 3 times. Would you like to reset your password?", preferredStyle: .alert)
        
        // Add a "Reset" button that calls the resetPassword() function if pressed.
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] action in
            self?.resetPassword()
        }
        // Add a "Cancel" button that does nothing if pressed.
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        // Add the actions to the alert.
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        // Present the alert to the user.
        present(alert, animated: true, completion: nil)
    }
    
    /**
     Resets the user's password and shows alerts if the user forgets their password three times.
     
     - Returns: Void.
     */
    func resetPassword() {
        // Check if the email field is not empty.
        if let email = emailTextField.text, !email.isEmpty {
            
            // Attempt to send a password reset email to the user's email address.
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                
                // If there was an error, notify the user.
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
            
            // If the email field is empty, notify the user.
            let alert = UIAlertController(title: "Please Check!", message: "Please enter your email address.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default,handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /**
     reset password with email field for user initiated password reset option
    
        - Returns:  Void.
     */
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        // Check if the email field is not empty.
        if let email = emailTextField.text, !email.isEmpty {
            
            // Attempt to send a password reset email to the user's email address.
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                
                //checks if there is an error
                if let error = error {
                    
                    //notify users
                    let alert = UIAlertController(title: "Please Check!", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    //notify users a password reset has been sent
                    let alert = UIAlertController(title: "Password reset email sent", message: "Please check your email inbox for instructions on how to reset your password.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            
            // If the email field is empty, notify the user.
            let alert = UIAlertController(title: "Please Check!", message: "Please enter your email address.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
