//
//  Event.swift
//  Motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Marcus Molchany. All rights reserved.
//

import Foundation
import MapKit

class Event: NSObject {
    var id: Int?
    var title: String?
    var desc: String?
    var startDate: NSDate?
    var endDate: NSDate?
    var categories: Array<EventCategory>?
    var createdBy: String?
    var isSubscribed: Bool?
    var subscribedUsers: Int?
    var address: String?
    var addressName: String?
    var location: CLLocation?
    var isReported: Bool = false
    var isApproved: Bool = false
    var page: Int!
    var index: Int!
    
    init(id: Int?, createdBy: String?, title: String?, desc: String?, startDate: NSDate?, endDate: NSDate?, categories: Array<Dictionary<String, AnyObject>>?, isSubscribed: Bool?, subscribedUsers: Int?, address: String?, addressName: String?, isApproved: Bool?, isReported: Bool?) {
        self.id = id
        self.createdBy = createdBy
        self.title = title
        self.desc = desc
        self.startDate = startDate
        self.endDate = endDate
        self.isSubscribed = isSubscribed
        self.subscribedUsers = subscribedUsers
        self.address = address
        self.addressName = addressName
        self.isApproved = isApproved!
        self.isReported = isReported!
        //self.location = coords
        self.categories = categories?.map({ (cat) -> EventCategory in
            return EventCategory(category: cat["category"]! as String, id: cat["id"]! as Int)
        })
    }
    
    func getParams() -> Dictionary<String, AnyObject!> {
        return [
            "name": self.title,
            "description": self.desc,
            "start": self.getFormattedStartDate(),
            "end": self.getFormattedEndDate(),
            "address": self.address,
            "address_name": self.addressName,
            "is_reported": self.isReported,
            "is_approved": self.isApproved
        ]
    }
    
    func getDisplayAddress() -> String {
        if self.addressName != nil && self.addressName?.utf16Count > 0 {
            return self.addressName!
        }
        return self.address!
    }
    
    func getImage() -> UIImage {
        let cat = self.categories!.first
        return cat!.image
    }
    
    func getCategoryTitle() -> String {
        return self.categories!.first!.category
    }
    
    func isInCategory(category: EventCategory) -> Bool {
        for cat in self.categories! {
            if cat.id == category.id {
                return true
            }
        }
        return false
    }
    
    func getFormattedDateRange() -> String {
        if self.startDate == nil || self.endDate == nil {
            return ""
        }
        if (self.startDate?.isOnSameDayAs(self.endDate!) != nil) {
            return self.getSameDayDateRange()
        } else {
            return self.getMultipleDayDateRange()
        }
    }
    
    func getFormattedDate(date: NSDate) -> String {
        let formatter = MotifiedDateFormatter(format: MotifiedDateFormat.Server)
        return formatter.stringFromDate(date)
    }
    
    func getFormattedStartDate() -> String {
        return self.getFormattedDate(self.startDate!)
    }
    
    func getFormattedEndDate() -> String {
        return self.getFormattedDate(self.endDate!)
    }
    
    func reportEvent(done: (NSError!) -> ()) {
        let params = [
            "is_reported": true
        ]
        let url = NSString(format: "api/events/%d" , self.id!)
        LoginManager.manager.PATCH(url, parameters: params,
            success: { (NSURLSessionDataTask, AnyObject) -> Void in
                done(nil)
            },
            failure: { (NSURLSessionDataTask, NSError) -> Void in
                done(NSError)
        })
    }
    
    private func getSameDayDateRange() -> String {
        let firstFormat = MotifiedDateFormatter(format: MotifiedDateFormat.ClientLong)
        let secondFormat = MotifiedDateFormatter(format: MotifiedDateFormat.ClientTimeOnly)
        let start = firstFormat.stringFromDate(self.startDate!.toLocalTime())
        let end = secondFormat.stringFromDate(self.endDate!.toLocalTime())
        return "\(start)-\(end)"
    }
    
    private func getMultipleDayDateRange() -> String {
        let format = MotifiedDateFormatter(format: MotifiedDateFormat.ClientLong)
        let start = format.stringFromDate(self.startDate!.toLocalTime())
        let end = format.stringFromDate(self.endDate!.toLocalTime())
        return "\(start)-\(end)"
    }
    
    func notifyUserOnDay() {
        let dateInterval = self.startDate!.toLocalTime().timeIntervalSinceNow - 60*60
        self.notifyUserAtInterval(dateInterval, message: "Event Starting In 1 Hour: \(self.title!)")
    }
    
    func notifyUserDayPrior() {
        let dateInterval = self.startDate!.toLocalTime().timeIntervalSinceNow - 60*60*24
        self.notifyUserAtInterval(dateInterval, message: "Event Tomorrow: \(self.title!)")
    }
    
    func notifyUserOnStart() {
        let dateInterval = self.startDate!.toLocalTime().timeIntervalSinceNow
        self.notifyUserAtInterval(dateInterval, message: "Event Starting Now: \(self.title!)")
    }
    
    func toggleNotify() {
        if self.isSubscribed! {
            self.cancelNotify()
        } else {
            self.notify()
        }
    }
    
    func cancelNotify() {
        
    }
    
    func notify() {
        if UserPreferenceManager.shouldAlert(PREF_DAY_PRIOR_KEY) {
            self.notifyUserDayPrior()
        }
        if UserPreferenceManager.shouldAlert(PREF_HOUR_PRIOR_KEY) {
            self.notifyUserOnDay()
        }
        if UserPreferenceManager.shouldAlert(PREF_ON_START_KEY) {
            self.notifyUserOnStart()
        }
    }
    
    func notifyUserAtInterval(interval: NSTimeInterval, message: String) {
        if interval < 0 {
            return ()
        }
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: interval)
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
