//
//  addBorder.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/27/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import Foundation

func addBorder(button: UIButton) -> Void {
    button.layer.borderWidth = 1.0
    button.layer.cornerRadius = 8.0
    button.layer.borderColor = UIColor.whiteColor().CGColor
    return ()
}

func addBorderMatchingBackground(button: UIButton) -> Void {
    button.layer.borderWidth = 1.0
    button.layer.cornerRadius = 8.0
    button.layer.borderColor = button.backgroundColor?.CGColor
    return ()
}