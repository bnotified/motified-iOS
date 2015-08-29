//
//  EventTableViewCell.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/15/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var subscribedLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var subscribedTextLabel: UILabel!
    @IBOutlet weak var subscriberContainer: UIView!
    
    var event: Event?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpWithEvent(event: Event) {
        self.event = event
        self.titleLabel.text = event.title
        self.categoryImage.image = event.getImage()
        
        let dateFormatter = MotifiedDateFormatter(format: MotifiedDateFormat.ClientLong)
        let start = dateFormatter.stringFromDate(event.startDate!.toLocalTime())
        let end = dateFormatter.stringFromDate(event.endDate!.toLocalTime())
        self.dateLabel.text = NSString(format: "%@ - %@", start, end) as String
        
        self.subscriberContainer.layer.borderColor = UIColor.whiteColor().CGColor
        self.subscriberContainer.layer.borderWidth = 1.0
        self.subscriberContainer.layer.cornerRadius = 8
        self.subscribedLabel.text = NSString(format: "%d", self.event!.subscribedUsers!) as String
        
        self.locationLabel.text = event.getDisplayAddress()
    }

}
