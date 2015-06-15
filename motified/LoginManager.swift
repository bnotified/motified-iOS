//
//  LoginManager.swift
//  Motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//

import UIKit

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
            APIManager.sharedInstance.loadEvents(nil)
            APIManager.sharedInstance.loadCategories(nil)
            success()
            }, failure: failure)
    }
    
    class func login(success: () -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
        let username = UserPreferenceManager.loadUsername()
        let password = UserPreferenceManager.loadPassword()
        self.loginWithUsername(username, password: password, success: success, failure: failure)
    }
    
    class func loginWithUsername(username: String, password: String, success: () -> Void, failure: (NSURLSessionDataTask!, NSError!) -> Void) -> Void {
        let m = self.manager
        m.requestSerializer.setAuthorizationHeaderFieldWithUsername(username, password: password)
        m.POST("user/login", parameters: nil, success: { (NSURLSessionDataTask, AnyObject) -> Void in
            UserPreferenceManager.saveUsernameAndPassword(username, password: password)
            let instance = APIManager.sharedInstance
            instance.currentPage = 1
            instance.loadEvents(nil)
            instance.loadCategories(nil)
            success()
        }, failure: failure)
    }
    
    class func testLogin() {
        self.login({ () -> Void in
            self.isLoggedIn({ (Bool, NSError) -> Void in
                if(Bool == true) {
                    NSLog("YAY")
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
    
    class func hasValidCookie() -> Bool {
        let cookie = self.getCookie()
        return (cookie != nil)
    }
    
    class func getCookies() -> Array<NSHTTPCookie> {
        return NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(NSURL(string: "http://localhost:5000/"))! as Array<NSHTTPCookie>
    }
    
    class func getCookie() -> NSHTTPCookie! {
        let cookies = self.getCookies()
        for cookie in cookies {
            if cookie.name == "motified_cookie" {
                return cookie
            }
        }
        return nil
    }
    
    class func logOut() {
        let cookie = self.getCookie()
        if cookie != nil {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }
    }
}
