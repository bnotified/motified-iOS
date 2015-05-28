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

let HAS_SET_ALERT_PREF: String = "has_set_alert_pref"

class UserPreferenceManager: NSObject {
    
    class func isAdmin() -> Bool {
        if !self.hasUsername() || !self.hasPassword() {
            return false
        }
        let u = self.loadUsername()
        let p = self.loadPassword()
        return (u == "admin" && p == "Smallwins1")
    }
    
    class func setPrefIfNecessary() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey(HAS_SET_ALERT_PREF) == false {
            self.setAlert(PREF_ON_START_KEY, shouldAlert: true)
            self.setAlert(PREF_DAY_PRIOR_KEY, shouldAlert: true)
            self.setAlert(PREF_HOUR_PRIOR_KEY, shouldAlert: true)
            self.setAlert(HAS_SET_ALERT_PREF, shouldAlert: true)
            self.save(defaults)
        }
    }
    
    class func shouldAlert(pref: String) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(pref)
    }
    
    class func setAlert(pref: String, shouldAlert: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(shouldAlert, forKey: pref)
        self.save(defaults)
    }
    
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
        if IS_OS_8_OR_LATER {
            defaults.synchronize()
        }
    }
}
