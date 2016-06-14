//
//  LoginSignupViewController.swift
//  Project_04
//
//  Created by Riccardo Sibani on 17/05/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class LoginSignupViewController: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("login")
        
        self.navigationController?.navigationBarHidden = true
        title = "MarketNote"
        
        let signUpVC = PFSignUpViewController()
        signUpVC.delegate = self
        self.delegate = self
        self.signUpController = signUpVC
        
        //confidure the logo
        logInView?.logo = UIImageView(image: UIImage(named: "Logo"))
        logInView?.logo?.contentMode = .ScaleAspectFit
        
        signUpVC.signUpView?.logo = UIImageView(image: UIImage(named: "Logo"))
        signUpVC.signUpView?.logo?.contentMode = .ScaleAspectFit
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showInbox(){
        self.navigationController?.popToRootViewControllerAnimated(true) // Go back to the previous view (FirstViewController)
    }
}

extension LoginSignupViewController : PFSignUpViewControllerDelegate
{
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
        showInbox()
    }
}

extension LoginSignupViewController : PFLogInViewControllerDelegate
{
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        showInbox()
    }
}