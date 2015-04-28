//
//  AuthManagingViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/14/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class AuthManagingViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var errorDisplay: UITextView!
    
    var shouldLogIn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBorder(self.registerBtn)
        addBorder(self.loginBtn)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if LoginManager.hasValidCookie() {
            self.didLogIn()
        }
        else if UserPreferenceManager.hasUsername() && UserPreferenceManager.hasPassword() {
            self.usernameTextField.text = UserPreferenceManager.loadUsername()
            self.passwordTextField.text = UserPreferenceManager.loadPassword()
            if self.shouldLogIn {
                self.login()
            }
        }
    }
    
    func showError(message: String) {
        self.errorDisplay.hidden = false
        self.errorDisplay.text = message
        self.errorDisplay.textColor = UIColor.redColor()
        self.errorDisplay.font = UIFont.systemFontOfSize(17.0)
    }
    
    func didLogIn() {
        self.performSegueWithIdentifier(SEGUE_ID_MAIN_TAB, sender: nil)
    }
    
    func login() {
        let username = UserPreferenceManager.loadUsername()
        let password = UserPreferenceManager.loadPassword()
        self.usernameTextField.text = username
        self.passwordTextField.text = password
        self.loginWithUsername(username, password: password)
    }
    
    func loginWithUsername(username: String, password: String) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        LoginManager.loginWithUsername(username, password: password,
            { () -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.didLogIn()
                return ()
            }, failure: { (NSURLSessionDataTask, NSError) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                if let response: NSHTTPURLResponse = NSURLSessionDataTask.response as? NSHTTPURLResponse {
                    NSLog("Status Code: %@", response)
                    if response.statusCode == 500 {
                        self.showError("Internal server error. Please try again latter")
                    } else if response.statusCode == 401 {
                        self.showError("Incorrect username/password combination")
                    }
                } else {
                    self.showError("Unable to reach server. Please check your internet connection.")
                }
        })
    }

    func register(username: String, password: String) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        LoginManager.registerUserWithUsername(username, password: password, confirm: password,
            success: { () -> Void in
                UserPreferenceManager.saveUsernameAndPassword(username, password: password)
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.didLogIn()
            })
            { (NSURLSessionDataTask, NSError) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                if let response: NSHTTPURLResponse = NSURLSessionDataTask.response as? NSHTTPURLResponse {
                    if response.statusCode == 400 {
                        self.showError("Whoops! The username \(username) is not available")
                    } else if response.statusCode == 500 {
                        self.showError("Internal server error. Please try again latter")
                    }
                    return ()
                }
                self.showError("An error occurred when registering. Please check your internet connectivity.")
        }
    }
    
    func isPasswordValid(password: String) -> Bool {
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        return (password.utf16Count >= 6 && password.rangeOfCharacterFromSet(whitespace) == nil)
    }
    
    func isUsernameValid(username: String) -> Bool {
        let validSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_")
        let invertedSet = validSet.invertedSet
        return (username.utf16Count >= 1 && username.rangeOfCharacterFromSet(invertedSet) == nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressRegister(sender: AnyObject) {
        let username = self.usernameTextField.text
        let password = self.passwordTextField.text
        if self.isUsernameValid(username) == false {
            return self.showError("A username be at least 1 character long and contain only alphaneumeric charcters and underscores")
        }
        if self.isPasswordValid(password) == false {
            return self.showError("A password must be at least 6 characters long and not contain any whitespace")
        }
        self.register(username, password: password)
    }
    
    @IBAction func didPressLogin(sender: AnyObject) {
        let username = self.usernameTextField.text
        let password = self.passwordTextField.text
        self.loginWithUsername(username, password: password)
    }
}
