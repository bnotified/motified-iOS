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
    
    init(id: Int?, createdBy: String?, title: String?, desc: String?, startDate: NSDate?, endDate: NSDate?, categories: Array<Dictionary<String, AnyObject>>?, isSubscribed: Bool?, subscribedUsers: Int?, address: String?, addressName: String?) {
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
        //self.location = coords
        self.categories = categories?.map({ (cat) -> EventCategory in
            return EventCategory(category: cat["category"]! as String, id: cat["id"]! as Int)
        })
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
        let start = firstFormat.stringFromDate(self.startDate!)
        let end = secondFormat.stringFromDate(self.endDate!)
        return "\(start)-\(end)"
    }
    
    private func getMultipleDayDateRange() -> String {
        let format = MotifiedDateFormatter(format: MotifiedDateFormat.ClientLong)
        let start = format.stringFromDate(self.startDate!)
        let end = format.stringFromDate(self.endDate!)
        return "\(start)-\(end)"
    }
}
