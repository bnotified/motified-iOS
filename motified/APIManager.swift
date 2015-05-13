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
    var currentPage: Int = 1
    
    class var sharedInstance: APIManager { return _APIManagerInstance }
    
    func reloadEvents(done: ((NSError!) -> Void)!) {
        self.currentPage = 1
        self.totalPages = 0
        self.events.removeAll(keepCapacity: true)
        self.loadEvents(done)
    }
    
    internal func loadEventsWithParams(params: Dictionary<String, AnyObject>!, done: ((NSError!) -> Void)!) {
        var finalParams: Dictionary<String, AnyObject>  = [
            "order_by": [["field":"start", "direction":"desc"]]
        ]
        if params != nil {
            finalParams.update(params)
        }
        if finalParams.indexForKey("filters") == nil {
            finalParams.updateValue([] as Array<Dictionary<String, AnyObject>>, forKey: "filters")
        }
        var filters: Array<Dictionary<String, AnyObject>> = finalParams["filters"]! as Array<Dictionary<String, AnyObject>>
        filters.append(["and": [["name":"is_approved", "op":"eq", "val": 1]]])
        finalParams.updateValue(filters, forKey: "filters")
        LoginManager.manager.GET(
            "/api/events",
            parameters: ["q": JSONStringify(finalParams), "page": self.currentPage, "results_per_page": 30],
            success: { (NSURLSessionDataTask, response) -> Void in
                self.currentPage++
                let json = response as Dictionary<String, AnyObject>
                self.setEventsFromResponse(json)
                if done != nil {
                    done(nil)
                }
                self.emitEventsChanged()
            }, { (NSURLSessionDataTask, NSError) -> Void in
                NSLog("Error loading events %@", NSError)
                if done != nil {
                    done(NSError)
                }
                self.emitEventsError()
        })
    }
    
    func loadEvents(done: ((NSError!) -> Void)!) {
        self.loadEventsWithParams(nil, done: done)
    }
    
    func loadEventsForSelectedCategories(done: ((NSError!) -> Void)!) {
        self.events.removeAll(keepCapacity: true)
        self.currentPage = 1
        if self.selectedCategories.count > 0 {
            let params: Dictionary<String, AnyObject> = self.getParamsForCategorySearch()
            self.loadEventsWithParams(params, done: done)
        } else {
            self.loadEvents(done)
        }
    }
    
    func toggleSubscription(event: Event, done: ((NSError!) -> Void)!) {
        if event.isSubscribed! {
            self.unsubscribeFromEvent(event, done: done)
        } else {
            self.subscribeToEvent(event, done: done)
        }
    }
    
    func subscribeToEvent(event: Event, done: ((NSError!) -> Void)!) {
        var data = ["event_id": event.id!]
        LoginManager.manager.POST("/api/event_subscriptions", parameters: data,
            success: { (NSURLSessionDataTask, AnyObject) -> Void in
                event.isSubscribed = true
                self.callDoneIfNotNil(done, withError: nil)
                self.emitEventsChanged()
            }, { (NSURLSessionDataTask, NSError) -> Void in
                self.callDoneIfNotNil(done, withError: NSError)
        })
    }
    
    func unsubscribeFromEvent(event: Event, done: ((NSError!) -> Void)!) {
        var data = ["filters": [["and" : [
            ["name":"event_id", "op":"eq", "val": event.id!]
        ]]]]
        var finalParams = ["q": JSONStringify(data)]
        LoginManager.manager.DELETE("/api/event_subscriptions", parameters: finalParams,
            success: { (NSURLSessionDataTask, AnyObject) -> Void in
                event.isSubscribed = false
                self.callDoneIfNotNil(done, withError: nil)
                self.emitEventsChanged()
            }, { (NSURLSessionDataTask, NSError) -> Void in
                self.callDoneIfNotNil(done, withError: NSError)
        })
    }
    
    func reportEvent(event: Event, done: ((NSError!) -> Void)!) {
        event.isReported = true
        self.updateEvent(event, done: done)
    }
    
    func updateEvent(event: Event, done: ((NSError!) -> Void)!) {
        let params = event.getParams()
        LoginManager.manager.PATCH("/api/event/\(event.id)", parameters: params,
            success: { (NSURLSessionDataTask, AnyObject) -> Void in
                self.callDoneIfNotNil(done, withError: nil)
                self.emitEventsChanged()
            }, { (NSURLSessionDataTask, NSError) -> Void in
                NSLog("Error updating event: %@", NSError)
                self.callDoneIfNotNil(done, withError: NSError)
        })
    }
    
    internal func getParamsForCategorySearch() -> Dictionary<String, AnyObject> {
        var categories: Array<EventCategory> = self.getSelectedCategories()
        if categories.count > 1 {
            var or: Array<Dictionary<String, AnyObject>> = []
            for category in categories {
                or.append(self.getCategoryFilterObject(category))
            }
            return ["filters": [["or": or]]];
            
        } else {
            return ["filters": [self.getCategoryFilterObject(categories.first!)]]
        }
    }
    
    internal func getCategoryFilterObject(category: EventCategory) -> Dictionary<String, AnyObject> {
        return ["name":"categories","op":"any", "val": ["name":"category","op":"eq", "val": category.category]]
    }
    
    func searchEvents(searchText: String, done: ((NSError!) -> Void)!) {
        let likeString = "%\(searchText)%"
        let params = [
            "filters": [["or":[
                ["name":"description","op":"like","val": likeString],
                ["name":"name","op":"like","val": likeString]
            ]]]
        ]
        self.currentPage = 1
        self.events.removeAll(keepCapacity: true)
        self.loadEventsWithParams(params, done: done)
    }
    
    func hasNextPage() -> Bool {
        return self.currentPage < self.totalPages
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
                self.callDoneIfNotNil(done, withError: nil)
            },
            { (NSURLSessionDataTask, NSError) -> Void in
                NSLog("Error loading categories: %@", NSError)
                self.emitCategoriesError()
                self.callDoneIfNotNil(done, withError: NSError)
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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        
        let num_results = response["num_results"]! as Int
        let objects = response["objects"]! as Array<AnyObject>
        let page = response["page"]! as Int
        self.totalPages = response["total_pages"]! as Int
        
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
    
    //    internal func filterToSelectedEvents(events: Array<Event>) -> Array<Event> {
    //        var filtered = NSMutableSet()
    //        for event in events {
    //            for index in self.selectedCategories {
    //                if let _index = index as? Int {
    //                    let category = self.categories[_index]
    //                    if event.isInCategory(category) {
    //                        filtered.addObject(event)
    //                    }
    //                }
    //            }
    //        }
    //        return filtered.allObjects as Array<Event>
    //    }
    
    func getEventsOnPage(page: Int) -> Array<Event> {
        if let events = self.events[page] {
            return events
        }
        return []
    }
    
    func getEventsInRange(page: Int) -> Array<Event> {
        var events = self.getEventsOnPage(1)
        for var i = 2; i <= page; i++ {
            events.extend(self.getEventsOnPage(i))
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
    
    func callDoneIfNotNil(done:((NSError!) -> Void)!, withError: NSError!) {
        if done != nil {
            done(withError)
        }
    }
}
