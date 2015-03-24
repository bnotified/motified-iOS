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
    
}
