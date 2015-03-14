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
}
