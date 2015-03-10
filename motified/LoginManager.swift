//
//  LoginManager.swift
//  Motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Marcus Molchany. All rights reserved.
//

import UIKit

let API_URL : String = "http://localhost:5000/api/"
let USERS_URL : String = "http://localhost:5000/api/users"

class LoginManager {
    
    class var manager: AFHTTPSessionManager {
        let manager = AFHTTPSessionManager(baseURL: NSURL(string: API_URL))
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        return manager
    }

    class func registerUserWithUsername(username: String, password: String, confirm: String, success: () -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
        // TODO: Handle password != confirm
        let params = [
            "username": username,
            "password": password,
            "confirm": confirm
        ]
        self.manager.POST("users", parameters: params, success: { (NSURLSessionDataTask, response) -> Void in
            var jsonResult = response as Dictionary<String, AnyObject>
            NSLog("Success: %@", jsonResult)
            success()
        }, failure: failure)
    }
    
    class func isLoggedIn() -> Bool {
        return true
    }
    
    class func getUsername() -> String {
        return "ganemone"
    }
    
}
