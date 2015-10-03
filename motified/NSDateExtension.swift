//
//  NSDateExtension.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/25/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import Foundation

extension NSDate {
    
    func isOnSameDayAs(date: NSDate) -> Bool {
        return NSDate.areDatesSameDay(self, dateTwo: date)
    }
    
    class func areDatesSameDay(dateOne:NSDate,dateTwo:NSDate) -> Bool {
        let calender = NSCalendar.currentCalendar()
        let flags: NSCalendarUnit = [NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year  ]
        let compOne: NSDateComponents = calender.components(flags, fromDate: dateOne)
        let compTwo: NSDateComponents = calender.components(flags, fromDate: dateTwo);
        return (compOne.day == compTwo.day && compOne.month == compTwo.month && compOne.year == compTwo.year);
    }
    
    func toLocalTime() -> NSDate {
        let tz = NSTimeZone.defaultTimeZone()
        let seconds = Double(tz.secondsFromGMT)
        return self.dateByAddingTimeInterval(seconds)
    }
    
    func toGlobalTime() -> NSDate {
        let tz = NSTimeZone.defaultTimeZone()
        let seconds = -Double(tz.secondsFromGMT)
        return self.dateByAddingTimeInterval(seconds)
    }
}