//
//  WelcomeViewController.swift
//  powerManager
//
//  Created by Paul Olphert on 15/01/2023.
//

import UIKit
import CLTypingLabel
class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: CLTypingLabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel!.text = K.appName
    }
    
}
