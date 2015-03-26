//
//  Category.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/26/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

func imageNameForCategoryID(id: Int) -> String {
    switch id {
    case 1: return "MusicalPerformances"
    case 2: return "SportingEvents"
    case 3: return "Lectures"
    case 4: return "Campus"
    case 5: return "LivePerformances"
    case 6: return "Party"
    case 7: return "Film"
    case 8: return "MindBodySpirit"
    case 9: return "ArtAndDesign"
    case 10: return "Environmental"
    case 11: return "OutdoorsAndAdventure"
    case 12: return "Technology"
    default: return "Food"
    }
}

class EventCategory: NSObject {
    
    var category: String
    var id: Int
    var image: UIImage
    
    init(category: String, id: Int) {
        self.category = category
        self.id = id
        self.image = UIImage(named:imageNameForCategoryID(id))
    }
}
