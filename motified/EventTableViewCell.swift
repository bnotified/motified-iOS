//
//  EventTableViewCell.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/15/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let event: Event?
    
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
        self.titleLabel.text = event.title
        self.categoryImage.image = event.getImage()
        self.descriptionLabel.text = event.desc
        let start = self.formatDate(event.startDate!)
        let end = self.formatDate(event.endDate!)
        self.dateLabel.text = NSString(format: "%@ - %@", start, end)
    }
    
    func formatDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d h':'mm a"
        return dateFormatter.stringFromDate(date)
    }
}