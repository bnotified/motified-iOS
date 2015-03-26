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
            [243, 156, 18,1.0],
            [26, 188, 156,1.0],
            [52, 152, 219,1.0],
            [46, 204, 113,1.0],
            [155, 89, 182,1.0],
            [52, 73, 94,1.0],
            [211, 84, 0,1.0],
            [192, 57, 43,1.0]
        ]
        let modIndex = (index >= 8) ? index % 8 : index
        let color = rgba(colors[modIndex])
        return color
    }
}
