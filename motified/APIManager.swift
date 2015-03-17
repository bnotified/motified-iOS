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
    
    var events: Dictionary<Int, Array<Event>> = Dictionary<Int, Array<Event>>(minimumCapacity: 5)
    var categories: Array<Dictionary<String, AnyObject>> = Array<Dictionary<String, AnyObject>>()
    var selectedCategories: NSMutableSet = NSMutableSet()
    var totalPages: Int = 0
    
    class var sharedInstance: APIManager { return _APIManagerInstance }
    
    func loadEvents(done: ((NSError!) -> Void)!) {
        LoginManager.manager.GET("/api/events", parameters: nil,
            success: { (NSURLSessionDataTask, response) -> Void in
                let json = response as Dictionary<String, AnyObject>
                self.setEventsFromResponse(json)
                self.emitEventsChanged()
                if done != nil {
                    done(nil)
                }
            },
            { (NSURLSessionDataTask, NSError) -> Void in
                self.emitEventsError()
                if done != nil {
                    done(NSError)
                }
        })
    }
    
    func loadCategories(done: ((NSError!) -> Void)!) {
        LoginManager.manager.GET("/api/categories", parameters: nil,
            success: { (NSURLSessionDataTask, response) -> Void in
                let json = response as Dictionary<String, AnyObject>
                self.categories = json["objects"]! as Array<Dictionary<String, AnyObject>>
                self.emitCategoriesChanged()
                if done != nil {
                    done(nil)
                }
            },
            { (NSURLSessionDataTask, NSError) -> Void in
                self.emitCategoriesError()
                if done != nil {
                    done(NSError)
                }
        })
    }
    
    func getSelectedCategories() -> Array<Dictionary<String, AnyObject>> {
        var selected: Array<Dictionary<String, AnyObject>> = Array<Dictionary<String, AnyObject>>()
        for index in self.selectedCategories {
            selected.append(self.categories[index as Int])
        }
        return selected
    }
    
    internal func emitEventsChanged() {
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_LOADED_EVENTS, object: nil)
    }
    
    internal func emitEventsError() {
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ERROR_EVENTS, object: nil)
    }
    
    internal func emitCategoriesChanged() {
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_LOADED_CATEGORIES, object: nil)
    }
    
    internal func emitCategoriesError() {
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ERROR_CATEGORIES, object: nil)
    }
    
    internal func setEventsFromResponse(response: Dictionary<String, AnyObject>) {
        // Set up date formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        
        let num_results = response["num_results"]! as Int
        let objects = response["objects"]! as Array<AnyObject>
        let page = response["page"]! as Int
        // self.totalPages = response["total_pages"]! as Int
        
        self.clearPage(page)
        
        for obj in objects {
            let id = obj["id"] as Int?
            let createdBy = obj["created_by"] as String?
            let name = obj["name"] as String?
            let desc = obj["description"] as String?
            let startStr = obj["start"] as String?
            let endStr = obj["end"] as String?
            let start =  dateFormatter.dateFromString(startStr!) as NSDate?
            let end = dateFormatter.dateFromString(endStr!) as NSDate?
            let categories = obj["categories"] as Array<Dictionary<String, AnyObject>>?
            let event = Event(id: id, createdBy: createdBy, title: name, desc: desc, startDate: start, endDate: end, categories: categories)
            self.events[page]?.append(event)
        }
    }
    
    internal func clearPage(page: Int) {
        self.events[page] = Array<Event>()
    }
    
    func getEventsOnPage(page: Int) -> Array<Event> {
        return self.events[page]!
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
