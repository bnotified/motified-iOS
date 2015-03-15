//
//  UserPreferenceManager.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/14/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

let USERNAME_KEY: String = "username_key"
let PASSWORD_KEY: String = "password_key"

class UserPreferenceManager: NSObject {
    
    class func loadUsername() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey(USERNAME_KEY)!
    }
    
    class func hasUsername() -> Bool {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey(USERNAME_KEY) != nil) {
            return true
        }
        return false
    }
    
    class func loadPassword() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey(PASSWORD_KEY)!
    }
    
    class func hasPassword() -> Bool {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey(PASSWORD_KEY) != nil) {
            return true
        }
        return false
    }
    
    class func saveUsername(username: String) -> Void {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(username, forKey: USERNAME_KEY)
        self.save(defaults)
    }
    
    class func savePassword(password: String) -> Void {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(password, forKey: PASSWORD_KEY)
        self.save(defaults)
    }
    
    class func saveUsernameAndPassword(username: String, password: String) -> Void {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(username, forKey: USERNAME_KEY)
        defaults.setObject(password, forKey: PASSWORD_KEY)
        self.save(defaults)
    }
    
    class func clearUsernameAndPassword() -> Void {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(USERNAME_KEY)
        defaults.removeObjectForKey(PASSWORD_KEY)
        self.save(defaults)
    }
    
    class internal func save(defaults: NSUserDefaults) -> Void {
        if !NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0)) {
            defaults.synchronize()
        }
    }
}