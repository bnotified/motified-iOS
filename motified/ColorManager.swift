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
            [26, 188, 156,1.0],
            [46, 204, 113,1.0],
            [52, 152, 219,1.0],
            [155, 89, 182,1.0],
            [52, 73, 94,1.0],
            //[22, 160, 133,1.0],
            //[39, 174, 96,1.0],
            //[41, 128, 185,1.0],
            //[142, 68, 173,1.0],
            //[44, 62, 80,1.0],
            //[241, 196, 15,1.0],
            //[230, 126, 34,1.0],
            //[231, 76, 60,1.0],
            [243, 156, 18,1.0],
            [211, 84, 0,1.0],
            [192, 57, 43,1.0]
        ]
        let modIndex = (index >= 8) ? index % 8 : index
        let color = rgba(colors[modIndex])
        return color
    }
}
