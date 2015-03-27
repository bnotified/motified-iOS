//
//  APIManager.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/15/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit
import MapKit

private let _APIManagerInstance = APIManager()

class APIManager: NSObject {
    
    var events: Dictionary<Int, Array<Event>> = Dictionary<Int, Array<Event>>(minimumCapacity: 5)
    var categories: Array<EventCategory> = Array<EventCategory>()
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
                NSLog("Error loading events: %@", NSError)
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
                let rawCategories = json["objects"]! as Array<Dictionary<String, AnyObject>>
                self.categories = rawCategories.map({ (cat) -> EventCategory in
                    return EventCategory(category: cat["category"]! as String, id: cat["id"]! as Int)
                })
                self.emitCategoriesChanged()
                if done != nil {
                    done(nil)
                }
            },
            { (NSURLSessionDataTask, NSError) -> Void in
                NSLog("Error loading categories: %@", NSError)
                self.emitCategoriesError()
                if done != nil {
                    done(NSError)
                }
        })
    }
    
    func getSelectedCategories() -> Array<EventCategory> {
        var selected: Array<EventCategory> = Array<EventCategory>()
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
        NSLog("Response: %@", response)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        
        let num_results = response["num_results"]! as Int
        let objects = response["objects"]! as Array<AnyObject>
        let page = response["page"]! as Int
        // self.totalPages = response["total_pages"]! as Int
        
        self.clearPage(page)
        
        for obj in objects {
            let startStr = obj["start"] as String?
            let endStr = obj["end"] as String?
            let start =  dateFormatter.dateFromString(startStr!) as NSDate?
            let end = dateFormatter.dateFromString(endStr!) as NSDate?
            let event = Event(
                id: obj["id"] as Int?,
                createdBy: obj["created_by"] as String?,
                title: obj["name"] as String?,
                desc: obj["description"] as String?,
                startDate: start,
                endDate: end,
                categories: obj["categories"] as Array<Dictionary<String, AnyObject>>?,
                isSubscribed: obj["is_subscribed"] as Bool?,
                subscribedUsers: obj["subscribed_users"] as Int?,
                address: obj["address"] as String?,
                addressName: obj["address_name"] as String?
            )
            self.events[page]?.append(event)
        }
    }
    
    internal func clearPage(page: Int) {
        self.events[page] = Array<Event>()
    }
    
    internal func filterToSelectedEvents(events: Array<Event>) -> Array<Event> {
        var filtered = NSMutableSet()
        for event in events {
            for index in self.selectedCategories {
                if let _index = index as? Int {
                    let category = self.categories[_index]
                    if event.isInCategory(category) {
                        filtered.addObject(event)
                    }
                }
            }
        }
        return filtered.allObjects as Array<Event>
    }
    
    func getEventsOnPage(page: Int) -> Array<Event> {
        let events = self.events[page]!
        if self.hasSelectedCategories() {
            return self.filterToSelectedEvents(events)
        }
        return events
    }
    
    func hasSelectedCategories() -> Bool {
        return self.selectedCategories.count > 0
    }
    
    func getSelectedCategoryMessage() -> String {
        if self.selectedCategories.count == 1 {
            let cat = self.getSelectedCategories()[0]
            let catString = cat.category
            return String(format: "Showing the %@ category", catString)
        }
        return String(format: "Showing categories: %@", ", ".join(self.getSelectedCategoryStrings()))
    }
    
    func getSelectedCategoryStrings() -> Array<String> {
        return self.getCategoryStrings(self.getSelectedCategories())
    }
    
    func getCategoryStrings(categories: Array<EventCategory>) -> Array<String> {
        return categories.map({ (cat: EventCategory) -> String in
            return cat.category
        })
    }
    
    func getCategoryIDs(categories: Array<EventCategory>) -> Array<Int> {
        return categories.map({ (cat: EventCategory) -> Int in
            return cat.id
        })
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
