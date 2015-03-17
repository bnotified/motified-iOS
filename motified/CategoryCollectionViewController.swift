//
//  CategoryCollectionViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/16/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

let reuseIdentifier = "CategoryCollectionViewCell"

class CategoryCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var hasShownToast: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up delegates
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // Set up listeners
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onCategoriesChanged", name: NOTIFICATION_LOADED_CATEGORIES, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.hasShownToast = false
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_LOADED_CATEGORIES, object: nil)
    }
    
    func showHelperToast() {
        self.view.makeToast("View the events feed to see only your selected categories", duration: 3, position: CSToastPositionCenter)
        self.hasShownToast = true
    }
    
    func onCategoriesChanged() {
        self.collectionView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return APIManager.sharedInstance.categories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var selectedIndexes = APIManager.sharedInstance.selectedCategories
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CategoryCollectionViewCell
        let categoryText = APIManager.sharedInstance.categories[indexPath.row]["category"]! as String
        cell.setUpWithImage(UIImage(named: "columns@3x.png"), text: categoryText)
        if selectedIndexes.containsObject(indexPath.row) {
            cell.checkImage.hidden = false
        } else {
            cell.checkImage.hidden = true
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.view.frame.size
        let width = size.width / 3 - 5*3
        return CGSizeMake(width, width + 20)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.hasShownToast == false {
            self.showHelperToast()
        }
        var selectedIndexes = APIManager.sharedInstance.selectedCategories
        if selectedIndexes.containsObject(indexPath.row) {
            selectedIndexes.removeObject(indexPath.row)
        } else {
            selectedIndexes.addObject(indexPath.row)
        }
        self.collectionView.reloadData()
    }
}
