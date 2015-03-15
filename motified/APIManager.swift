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
    
    var events: Array<Event>
    var page: Int
    var totalPages: Int
    
    class var sharedInstance: APIManager { return _APIManagerInstance }
    
    override init() {
        self.events = []
        self.page = 0
        self.totalPages = 0
    }
    
    func loadEvents(done: (NSError!) -> Void) {
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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        let num_results = response["num_results"]! as Int
        let objects = response["objects"]! as Array<AnyObject>
        self.page = response["page"]! as Int
        self.totalPages = response["total_pages"]! as Int
        for obj in objects {
            let id = obj["id"]! as Int
            NSLog("OBJ: %@", obj as Dictionary<String, AnyObject>)
            let createdBy = obj["created_by"]! as String
            let name = obj["name"]! as String
            let desc = obj["description"]! as String
            let startStr = obj["start"]! as String
            let endStr = obj["end"]! as String
            let start =  dateFormatter.dateFromString(startStr) as NSDate!
            let end = dateFormatter.dateFromString(endStr) as NSDate!
            NSLog("Start: %@", start)
            let cat = "temp"
            events.append(Event(id: id, createdBy: 1, title: name, desc: description, startDate: start!, endDate: end!, category: Category.Education))
        }
    }
    
//    func testEvents() {
//        let now: NSDate = NSDate()
//        let tomorrow = now.dateByAddingTimeInterval(60*60*24)
//        let end = tomorrow.dateByAddingTimeInterval(60*60)
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
//        let start = dateFormatter.stringFromDate(tomorrow)
//        let endstr = dateFormatter.stringFromDate(end)
//        let params = [
//            "name": "Another Event",
//            "subtitle": "Another Event Subtitle",
//            "description": "Another Event Description",
//            "start": start,
//            "end": endstr
//        ]
//        let params2 = [
//            "name": "A different Event",
//            "subtitle": "A Different Subtitle",
//            "description": "A different Description",
//            "start": start,
//            "end": endstr
//        ]
//        LoginManager.manager.POST("api/events", parameters: params, success: { (NSURLSessionDataTask, AnyObject) -> Void in
//            NSLog("Success")
//        }, { (NSURLSessionDataTask, NSError) -> Void in
//            NSLog("Failure: %@", NSError)
//        })
//        LoginManager.manager.POST("api/events", parameters: params2, success: { (NSURLSessionDataTask, AnyObject) -> Void in
//            NSLog("Success")
//            }, { (NSURLSessionDataTask, NSError) -> Void in
//                NSLog("Failure: %@", NSError)
//        })
//    }
    
    
}
