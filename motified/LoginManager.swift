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
        self.manager.POST("api/users", parameters: params, success: { (NSURLSessionDataTask, response) -> Void in
            var jsonResult = response as Dictionary<String, AnyObject>
            NSLog("Success: %@", jsonResult)
            success()
            }, failure: failure)
    }
    
    class func login(success: () -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
        let m = self.manager
        let username = UserPreferenceManager.loadUsername()
        let password = UserPreferenceManager.loadPassword()
        m.requestSerializer.setAuthorizationHeaderFieldWithUsername(username, password: password)
        m.POST("user/login", parameters: nil,
            success: { (NSURLSessionDataTask, AnyObject) -> Void in
                success()
            },
            failure: { (NSURLSessionDataTask, NSError) -> Void in
                let response: NSHTTPURLResponse = NSURLSessionDataTask.response as NSHTTPURLResponse
                if response.statusCode == 401 {
                    UserPreferenceManager.clearUsernameAndPassword()
                }
                failure(NSURLSessionDataTask, NSError)
            }
        )
    }
    
    class func testLogin() {
        self.login({ () -> Void in
            self.isLoggedIn({ (Bool, NSError) -> Void in
                if(Bool == true) {
                    NSLog("YAY");
                } else {
                    NSLog("POOP")
                }
            })
            }, failure: { (NSURLSessionDataTask, NSError) -> Void in
                NSLog("Failed to Login: %@", NSError)
        })
    }
    
    class func isLoggedIn(done: (Bool!, NSError!) -> Void) -> Void {
        self.manager.GET("user/isLoggedIn", parameters: nil, success: { (NSURLSessionDataTask, response) -> Void in
            let jsonResult: Dictionary<String, AnyObject> = response as Dictionary<String, AnyObject>
            let result: Bool = jsonResult["isLoggedIn"]! as Bool
            done(result, nil)
            }) { (NSURLSessionDataTask, NSError) -> Void in
                NSLog("Error: %@", NSError)
                done(nil, NSError)
        }
    }
}
