//
//  CategoryCollectionViewCell.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/16/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    var category: EventCategory!
    
    func setUpWithCategory(category: EventCategory) {
        self.category = category
        self.imageView.image = category.image
        self.titleLabel.text = category.category
    }
    
    override func translatesAutoresizingMaskIntoConstraints() -> Bool {
        return true
    }
}
