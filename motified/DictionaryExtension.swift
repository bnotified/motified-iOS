//
//  DictionaryExtension.swift
//  motified
//
//  Created by Giancarlo Anemone on 5/7/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}