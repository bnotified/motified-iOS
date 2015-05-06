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
    
    var isSelected: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpWithCategory(category: EventCategory) {
        self.titleLabel.text = category.category
        self.categoryImageView.image = category.image
        self.accessoryType = UITableViewCellAccessoryType.None
    }
    
    func setSelected() {
        self.isSelected = true
        self.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    func setUnselected() {
        self.isSelected = false
        self.accessoryType = UITableViewCellAccessoryType.None
    }

}
