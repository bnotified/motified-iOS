//
//  CategoryTableViewCell.swift
//  motified
//
//  Created by Giancarlo Anemone on 5/5/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var checkImage: UIImageView!
    
    var isSelected: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpWithCategory(category: EventCategory) {
        self.titleLabel.text = category.category
        self.categoryImageView.image = category.image
        //self.checkImage.hidden = true
    }
    
    func setSelected() {
        self.checkImage.hidden = false
        self.isSelected = true
    }
    
    func setUnselected() {
        self.checkImage.hidden = true
        self.isSelected = false
    }

}
