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
    
    func setUpWithImage(image: UIImage, text: String) {
        self.imageView.image = image
        self.titleLabel.text = text
    }
    
    override func translatesAutoresizingMaskIntoConstraints() -> Bool {
        return true
    }
}
