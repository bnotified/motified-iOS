//
//  EventTableViewCell.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/15/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var endsLabel: UILabel!
    @IBOutlet weak var beginsLabel: UILabel!
    @IBOutlet weak var beginsValueLabel: UILabel!
    @IBOutlet weak var endsValLabel: UILabel!
    
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
        self.descriptionTextView.text = event.desc
        self.endsValLabel.text = self.formatDate(event.startDate!)
        self.beginsValueLabel.text = self.formatDate(event.endDate!)
    }
    
    func formatDate(date: NSDate) -> String {
        return "10:00 am"
    }
}
