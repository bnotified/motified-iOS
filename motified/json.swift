//
//  json.swift
//  motified
//
//  Created by Giancarlo Anemone on 5/5/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import Foundation

func JSONStringify(value: AnyObject) -> String {
    if NSJSONSerialization.isValidJSONObject(value) {
        if let data = try? NSJSONSerialization.dataWithJSONObject(value, options: []) {
            if let string: String? = NSString(data: data, encoding: NSUTF8StringEncoding) as String? {
                return string!
            }
        }
    }
    return ""
}