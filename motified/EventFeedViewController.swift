//
//  EventFeedViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class EventFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var events: Array<Event> = Array<Event>()
    var currentPage: Int = 1
    var debouncedSearch: (()->())? = nil
    var isSearchShown = false
    var wasShowingSelected = false
    var sunnyRefreshControl: YALSunnyRefreshControl?
    
    @IBOutlet weak var segmentControlView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "onEventsChanged", name: NOTIFICATION_LOADED_EVENTS, object: nil)
        center.addObserver(self, selector: "onEventsChanged", name: NOTIFICATION_SELECTED_EVENTS_CHANGED, object: nil)
        center.addObserver(self, selector: "onEventsError", name: NOTIFICATION_ERROR_EVENTS, object: nil)
        self.searchBar.delegate = self
        self.debouncedSearch = debounce(NSTimeInterval(0.25), dispatch_get_main_queue(), self.makeRequest)
        self.sunnyRefreshControl = YALSunnyRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "sunnyControlDidStartAnimation", delegate: self)
        if UserPreferenceManager.isAdmin() {
            self.segmentedControl.addTarget(self, action: "onSegmentChanged", forControlEvents: UIControlEvents.ValueChanged)
            self.segmentControlView.hidden = false
        } else {
            self.segmentControlView.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let manager = APIManager.sharedInstance
        if (self.wasShowingSelected && !manager.hasSelectedCategories()) {
            self.wasShowingSelected = false
            MBProgressHUD(forView: self.view).show(true)
            manager.reloadEvents({ (NSError) -> Void in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                return ()
            })
        }
        else if (manager.hasSelectedCategories()) {
            self.wasShowingSelected = true
            self.navigationController?.navigationBar.makeToast(
                manager.getSelectedCategoryMessage(), duration: 2, position: CSToastPositionTop
            )
            MBProgressHUD(forView: self.view).show(true)
            manager.loadEventsForSelectedCategories({ (NSError) -> Void in
                NSLog("Done Loading")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                return ()
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_ID_EVENT_DETAIL {
            let event = sender as Event
            let dest = segue.destinationViewController as EventDetailViewController
            dest.event = event
        }
    }
    
    func onSegmentChanged() {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            APIManager.sharedInstance.reloadEvents(nil)
        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            APIManager.sharedInstance.loadUnapprovedEvents(nil)
        } else {
            APIManager.sharedInstance.loadReportedEvents(nil)
        }
    }
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: NOTIFICATION_LOADED_EVENTS, object: nil)
        center.removeObserver(self, name: NOTIFICATION_SELECTED_EVENTS_CHANGED, object: nil)
        center.removeObserver(self, name: NOTIFICATION_ERROR_EVENTS, object: nil)
    }
    
    func sunnyControlDidStartAnimation() {
        APIManager.sharedInstance.reloadEvents({ (NSError) -> Void in
            delay(0.5, { () -> () in
                self.sunnyRefreshControl?.endRefreshing()
                return ()
            })
        })
    }
    
    func makeRequest() {
        if self.searchBar.text.utf16Count == 0 {
            NSLog("Changed to nothing")
            if self.events.count == 0 {
                APIManager.sharedInstance.reloadEvents(nil)
            }
            return ()
        }
        NSLog("Making Request: %@", self.searchBar.text)
        APIManager.sharedInstance.searchEvents(self.searchBar.text, done: { (NSError) -> Void in
        })
    }
    
    func onEventsChanged() {
        self.events = APIManager.sharedInstance.getEventsInRange(self.currentPage)
        self.tableView.reloadData()
        if self.events.count == 0 {
            self.tableView.makeToast("No Results", duration: 2, position: CSToastPositionCenter)
        }
    }
    
    func onEventsError() {
        self.tableView.makeToast("Error loading events", duration: 2, position: CSToastPositionCenter)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let apiManager = APIManager.sharedInstance
        if (indexPath.row == self.events.count - 1 && apiManager.hasNextPage() && !self.isSearching()) {
            self.currentPage++
            loadEvents()
        }
        var cell = tableView.dequeueReusableCellWithIdentifier("EventTableViewCell", forIndexPath: indexPath) as EventTableViewCell
        let ev = self.getEventAtIndexPath(indexPath)
        cell.setUpWithEvent(ev)
        cell.contentView.backgroundColor = ColorManager.getColorForIndex(indexPath.row)
        return cell
    }
    
    func getEventAtIndexPath(indexPath: NSIndexPath) -> Event {
        return self.events[indexPath.row]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Selected row")
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let event = self.getEventAtIndexPath(indexPath)
        self.performSegueWithIdentifier(SEGUE_ID_EVENT_DETAIL, sender: event)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.debouncedSearch!();
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.isSearchShown = false
        self.currentPage = 1
        loadEvents()
        searchBar.resignFirstResponder()
        self.searchBarConstraint.constant = -44
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            return ()
            }, completion: nil)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func loadEvents() {
        APIManager.sharedInstance.loadEvents { (NSError) -> Void in
            if (NSError != nil) {
                if self.currentPage > 1 {
                    self.currentPage--
                }
                return ()
            }
        }
    }
    
    @IBAction func onSearchButtonClicked(sender: AnyObject) {
        self.searchBarConstraint.constant = (self.isSearchShown) ? -44 : 0
        self.isSearchShown = !self.isSearchShown
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            if !self.isSearchShown {
                self.searchBar.resignFirstResponder()
            }
            return ()
            }, completion: nil)
    }
    
    func isSearching() -> Bool {
        return self.searchBar.text.utf16Count > 0
    }
}

