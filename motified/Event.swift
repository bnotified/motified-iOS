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
    let id: Int
    let title: String
    let subtitle: String
    let desc: String
    let startDate: NSDate
    let endDate: NSDate
    let category: Category
    
    init(id: Int, title: String, subtitle: String, desc: String, startDate: NSDate, endDate: NSDate, category: Category) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.desc = desc
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
    }
}
