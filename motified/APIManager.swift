//
//  APIManager.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/15/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

private let _APIManagerInstance = APIManager()

class APIManager: NSObject {
    
    var events: Array<Event> = []
    
    class var sharedInstance: APIManager { return _APIManagerInstance }
    
    internal func loadEvents(done: (NSError!) -> Void) {
        LoginManager.manager.GET("/api/events", parameters: nil,
            success: { (NSURLSessionDataTask, response) -> Void in
                let json = response as Dictionary<String, AnyObject>
                self.setEventsFromResponse(json)
                done(nil)
            },
            { (NSURLSessionDataTask, NSError) -> Void in
                done(NSError)
        })
    }
    
    internal func setEventsFromResponse(response: Dictionary<String, AnyObject>) {
        NSLog("Response: %@", response)
    }
}
