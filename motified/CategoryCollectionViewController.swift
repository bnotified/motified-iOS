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
    
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var hasShownToast: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up delegates
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.backgroundColor = ColorManager.getColorPurple()
        
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
        self.navigationController?.navigationBar.makeToast("Events feed updated", duration: 2, position: CSToastPositionTop)
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
        let category = APIManager.sharedInstance.categories[indexPath.row] as EventCategory
        cell.setUpWithCategory(category)
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
        return CGSizeMake(width, width + 30)
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
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SELECTED_EVENTS_CHANGED, object: nil)
        self.collectionView.reloadData()
    }
    
    
    @IBAction func onClearPressed(sender: AnyObject) {
        APIManager.sharedInstance.selectedCategories = NSMutableSet()
        self.collectionView.reloadData()
    }
    
    @IBAction func onBackButtonPressed(sender: AnyObject) {
        self.tabBarController?.selectedIndex = 0
    }
    
}
