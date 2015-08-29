//
//  CategoryListViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 5/5/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit


class CategoryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    
    var hasShownToast: Bool = false
    let reuseIdentifier = "CategoryTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up listeners
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onCategoriesChanged", name: NOTIFICATION_LOADED_CATEGORIES, object: nil)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorInset = UIEdgeInsetsZero
        if IS_OS_8_OR_LATER {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.hasShownToast = false
        self.tableView.reloadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_LOADED_CATEGORIES, object: nil)
    }
    
    func showHelperToast() {
        self.navigationController?.navigationBar.makeToast("Events feed updated", duration: 2, position: CSToastPositionTop)
        self.hasShownToast = true
    }
    
    func onCategoriesChanged() {
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIManager.sharedInstance.categories.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var selectedIndexes = APIManager.sharedInstance.selectedCategories
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CategoryTableViewCell
        cell.backgroundColor = ColorManager.getColorPurple()
        let category = APIManager.sharedInstance.categories[indexPath.row] as EventCategory
        cell.setUpWithCategory(category)
        if selectedIndexes.containsObject(indexPath.row) {
            cell.setSelected()
        } else {
            cell.setUnselected()
        }
        cell.separatorInset = UIEdgeInsetsZero
        
        if IS_OS_8_OR_LATER {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.hasShownToast == false {
            self.showHelperToast()
        }
        var selectedIndexes = APIManager.sharedInstance.selectedCategories
        if selectedIndexes.containsObject(indexPath.row) {
            selectedIndexes.removeObject(indexPath.row)
        } else {
            selectedIndexes.addObject(indexPath.row)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SELECTED_EVENTS_CHANGED, object: nil)
        self.tableView.reloadData()
    }
    
    @IBAction func onClearPressed(sender: AnyObject) {
        APIManager.sharedInstance.selectedCategories = NSMutableSet()
        self.tableView.reloadData()
    }
    
    @IBAction func onBackButtonPressed(sender: AnyObject) {
        self.tabBarController?.selectedIndex = 0
    }
    
}
