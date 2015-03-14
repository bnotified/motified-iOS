//
//  AuthManagingViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/14/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class AuthManagingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (UserPreferenceManager.hasUsername()) {
            self.login()
        } else {
            self.promptForRegistration()
        }
    }
    
    func promptForRegistration(message: String?=nil) {
        var inputBox = BMInputBox.boxWithStyle(.LoginAndPasswordInput)
        inputBox.customiseInputElement = {(element: UITextField) in
            if element.secureTextEntry == true {
                element.placeholder = "Password"
            } else {
                element.placeholder = "Username"
            }
            return element
        }
        inputBox.title = "Register for B'Notified"
        if (message != nil) {
            inputBox.message = message;
        }
        inputBox.onSubmit = {(value: AnyObject...) in
            let results: Array<String> = value as Array<String>
            let username: String = results[0]
            let password: String = results[1]
            if (!self.isUsernameValid(username)) {
                return self.handleRegistrationError("A username is required, and must contain only letters, numbers, and underscores")
            }
            if (!self.isPasswordValid(password)) {
                return self.handleRegistrationError("A password must be at least 6 characters long and not contain any whitespace")
            }
            
        }
        inputBox.show()
    }
    
    func handleRegistrationError(message: String) -> Void {
        delay(0.5) {
            self.promptForRegistration(message: message)
        }
    }
    
    func login() {
    }
    
    func register(username: String, password: String) {
        let hud: MBProgressHUD = MBProgressHUD(view: self.view)
        hud.labelText = "Registering User"
        hud.show(true)
        LoginManager.registerUserWithUsername(username, password: password, confirm: password, success: { () -> Void in
            UserPreferenceManager.saveUsernameAndPassword(username, password: password)
            hud.hide(true)
        }) { (NSURLSessionDataTask, NSError) -> Void in
            self.promptForRegistration(message: "Error when registering")
            hud.hide(true)
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
}
