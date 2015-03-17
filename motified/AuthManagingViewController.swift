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
        super.viewDidAppear(animated)
        if LoginManager.hasValidCookie() {
            return ()
        }
        if UserPreferenceManager.hasUsername() {
            self.login()
        } else {
            self.promptForRegistration()
        }
    }
    
    func promptForRegistration(message: String?=nil) {
        var inputBox = BMInputBox.boxWithStyle(.LoginAndPasswordInput)
        self.customizeInput(inputBox)
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
            self.register(username, password: password)
        }
        inputBox.show()
    }
    
    func handleRegistrationError(message: String) -> Void {
        delay(0.5) {
            self.promptForRegistration(message: message)
        }
    }
    
    func login() {
        let username = UserPreferenceManager.loadUsername()
        let password = UserPreferenceManager.loadPassword()
        self.loginWithUsername(username, password: password)
    }
    
    func loginWithUsername(username: String, password: String) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        LoginManager.loginWithUsername(username, password: password,
            { () -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                return ()
            }, failure: { (NSURLSessionDataTask, NSError) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                let username = UserPreferenceManager.loadUsername()
                let password = UserPreferenceManager.loadPassword()
                let message = NSString(format: "Failed to login with username: %@ and password: %@", username, password)
                self.promptForLogin(message: message)
        })
    }
    
    func promptForLogin(message: String?=nil) -> Void {
        var inputBox = BMInputBox.boxWithStyle(.LoginAndPasswordInput)
        self.customizeInput(inputBox)
        inputBox.title = "Login"
        inputBox.message = message
        inputBox.cancelButtonText = "Need an Account"
        inputBox.onSubmit = {(value: AnyObject...) in
            let results: Array<String> = value as Array<String>
            let username: String = results[0]
            let password: String = results[1]
        }
        inputBox.onCancel = {() -> Void in
            self.promptForRegistration()
        }
        inputBox.show()
    }
    
    func customizeInput(inputBox: BMInputBox) -> Void {
        inputBox.customiseInputElement = {(element: UITextField) in
            if element.secureTextEntry == true {
                element.placeholder = "Password"
            } else {
                element.placeholder = "Username"
            }
            return element
        }
    }
    
    func register(username: String, password: String) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        LoginManager.registerUserWithUsername(username, password: password, confirm: password,
            success: { () -> Void in
                UserPreferenceManager.saveUsernameAndPassword(username, password: password)
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.view.makeToast("Successfully registered", duration: 2.0, position: CSToastPositionCenter)
            })
            { (NSURLSessionDataTask, NSError) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                let response: NSHTTPURLResponse = NSURLSessionDataTask.response as NSHTTPURLResponse!
                if response.statusCode == 400 {
                    self.promptForRegistration(message: NSString(format: "Whoops! The username '%@' is not available", username))
                } else {
                    self.promptForRegistration(message: "An error occurred when registering. Please check your internet connectivity")
                }
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
