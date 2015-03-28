//
//  ColorManager.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/25/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

func rgba(data: Array<CGFloat>) -> UIColor {
    return UIColor(red: data[0]/255, green: data[1]/255, blue: data[2]/255, alpha: 1.0)
}

class ColorManager: NSObject {
    
    class func getColorForIndex(index: Int) -> UIColor {
        
        let colors: Array<Array<CGFloat>> = [
            [26, 188, 156,1.0], // Turquoise
            [155, 89, 182,1.0], // Purple
            [192, 57, 43,1.0],  // Red
            [243, 156, 18,1.0], // Orange
            [52, 152, 219,1.0], // Blue
            [46, 204, 113,1.0], // Green
            [211, 84, 0,1.0],   // Red/Orange
            [52, 73, 94,1.0],   // Dark Blue
        ]
        let modIndex = (index >= 8) ? index % 8 : index
        let color = rgba(colors[modIndex])
        return color
    }
    
    class func getRandomColor() -> UIColor {
        let rand = Int(arc4random_uniform(8))
        NSLog("Index: %d", rand)
        return getColorForIndex(rand)
    }
    
    class func getColorPurple() -> UIColor {
        return self.getColorForIndex(1)
    }
}
