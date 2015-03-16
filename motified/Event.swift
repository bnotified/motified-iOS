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
    let category: Category?
    let createdBy: Int?
    
    init(id: Int?, createdBy: Int?, title: String?, desc: String?, startDate: NSDate?, endDate: NSDate?, category: Category?) {
        self.id = id
        self.createdBy = createdBy
        self.title = title
        self.desc = desc
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
    }
    
    func getImage() -> UIImage {
        return UIImage(named: "airplane")
    }
    
}
