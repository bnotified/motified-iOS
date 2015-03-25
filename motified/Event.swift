//
//  Event.swift
//  Motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Marcus Molchany. All rights reserved.
//

import Foundation

enum Category {
    case Education
    case Travel
    case Music
}

class Event: NSObject {
    let id: Int?
    let title: String?
    let desc: String?
    let startDate: NSDate?
    let endDate: NSDate?
    let categories: Array<Dictionary<String, AnyObject>>?
    let createdBy: String?
    
    init(id: Int?, createdBy: String?, title: String?, desc: String?, startDate: NSDate?, endDate: NSDate?, categories: Array<Dictionary<String, AnyObject>>?) {
        self.id = id
        self.createdBy = createdBy
        self.title = title
        self.desc = desc
        self.startDate = startDate
        self.endDate = endDate
        self.categories = categories
    }
    
    func getImage() -> UIImage {
        return UIImage(named: "Food.png")
    }
    
    func isInCategory(category: Dictionary<String, AnyObject>) -> Bool {
        for cat in self.categories! {
            if cat["category"]! as String == category["category"]! as String {
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
    
    internal func getSameDayDateRange() -> String {
        let firstFormat = MotifiedDateFormatter(format: MotifiedDateFormat.ClientLong)
        let secondFormat = MotifiedDateFormatter(format: MotifiedDateFormat.ClientTimeOnly)
        let start = firstFormat.stringFromDate(self.startDate!)
        let end = secondFormat.stringFromDate(self.endDate!)
        return "\(start)-\(end)"
    }
    
    internal func getMultipleDayDateRange() -> String {
        let format = MotifiedDateFormatter(format: MotifiedDateFormat.ClientLong)
        let start = format.stringFromDate(self.startDate!)
        let end = format.stringFromDate(self.endDate!)
        return "\(start)-\(end)"
    }
    
}
