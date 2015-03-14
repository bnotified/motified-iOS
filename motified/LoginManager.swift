//
//  LoginManager.swift
//  Motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Marcus Molchany. All rights reserved.
//

import UIKit

let BASE_URL: String = "http://localhost:5000/"

class LoginManager {
    
    class var manager: AFHTTPSessionManager {
        let manager = AFHTTPSessionManager(baseURL: NSURL(string: BASE_URL))
        let username = UserPreferenceManager.loadUsername()
        let password = UserPreferenceManager.loadPassword()
        manager.requestSerializer = AFJSONRequestSerializer()
        //manager.requestSerializer = AFHTTPRequestSerializer()
        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(username, password: password)
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
        self.manager.POST("api/users", parameters: params, success: { (NSURLSessionDataTask, response) -> Void in
            var jsonResult = response as Dictionary<String, AnyObject>
            NSLog("Success: %@", jsonResult)
            success()
            }, failure: failure)
    }
    
    class func login(success: () -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
        self.manager.POST("user/login", parameters: nil, success: { (NSURLSessionDataTask, AnyObject) -> Void in
            success()
            }, failure: failure)
    }
    
    class func testLogin() {
        self.login({ () -> Void in
            self.isLoggedIn({ (Bool, NSError) -> Void in
            })
            }, failure: { (NSURLSessionDataTask, NSError) -> Void in
                NSLog("Failed to Login: %@", NSError)
        })
    }
    
    class func isLoggedIn(done: (Bool!, NSError!) -> Void) -> Void {
        self.manager.GET("user/isLoggedIn", parameters: nil, success: { (NSURLSessionDataTask, response) -> Void in
            let jsonResult: Dictionary<String, AnyObject> = response as Dictionary<String, AnyObject>
            NSLog("Result: %@", jsonResult)
            done(true, nil)
            }) { (NSURLSessionDataTask, NSError) -> Void in
                NSLog("Error: %@", NSError)
                done(nil, NSError)
        }
    }
}
