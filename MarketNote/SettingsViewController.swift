//
//  SettingsViewController.swift
//  MarketNote
//
//  Created by Riccardo Sibani on 09/06/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UITextFieldDelegate {

    
    // MARK: - Components
    
    @IBOutlet weak var monthlyCeilingLabel: UITextField!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.hideKeyboardWhenTappedAround()
        
        let currentUser = PFUser.currentUser()
        
        if let ceiling = currentUser!["monthly"] {
            monthlyCeilingLabel.text = ceiling as! String
        }

    }

  
    @IBAction func Update(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        if let ceiling = monthlyCeilingLabel.text {
            currentUser!["monthly"] = ceiling
            
            currentUser?.saveInBackground()
        }
        
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
