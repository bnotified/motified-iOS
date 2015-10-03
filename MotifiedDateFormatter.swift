//
//  MotifiedDateFormatter.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/17/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

enum MotifiedDateFormat {
    case Server
    case ClientLong
    case ClientShort
    case ClientTimeOnly
}

class MotifiedDateFormatter: NSDateFormatter {
    init(format: MotifiedDateFormat) {
        super.init()
        switch format {
        case MotifiedDateFormat.Server:
            self.timeZone = NSTimeZone(name: "UTC")
            self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        case MotifiedDateFormat.ClientLong:
            self.locale = NSLocale.currentLocale()
            self.timeZone = NSTimeZone.localTimeZone()
            self.dateFormat = "MMM d h':'mm a"
        case MotifiedDateFormat.ClientShort:
            self.locale = NSLocale.currentLocale()
            self.timeZone = NSTimeZone.localTimeZone()
            self.dateFormat = "MMM d h':'mm a"
        case MotifiedDateFormat.ClientTimeOnly:
            self.locale = NSLocale.currentLocale()
            self.timeZone = NSTimeZone.localTimeZone()
            self.dateFormat = "h':'mm a"
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
