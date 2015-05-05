//
//  FirstViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class EventFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var events: Array<Event> = Array<Event>()
    var currentPage: Int = 1
    var debouncedSearch: (()->())? = nil
    
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let manager = APIManager.sharedInstance
        if (manager.hasSelectedCategories()) {
            self.view.makeToast(manager.getSelectedCategoryMessage(), duration: 2, position: CSToastPositionCenter)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_ID_EVENT_DETAIL {
            let event = sender as Event
            let dest = segue.destinationViewController as EventDetailViewController
            dest.event = event
        }
    }
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: NOTIFICATION_LOADED_EVENTS, object: nil)
        center.removeObserver(self, name: NOTIFICATION_SELECTED_EVENTS_CHANGED, object: nil)
        center.removeObserver(self, name: NOTIFICATION_ERROR_EVENTS, object: nil)
    }
    
    func makeRequest() {
        if self.searchBar.text.utf16Count == 0 {
            NSLog("Changed to nothing")
            return ()
        }
        NSLog("Making Request: %@", self.searchBar.text)
        APIManager.sharedInstance.searchEvents(self.searchBar.text, done: { (NSError) -> Void in
            NSLog("Done searching")
        })
    }
    
    func onEventsChanged() {
        self.events = APIManager.sharedInstance.getEventsInRange(self.currentPage)
        self.tableView.reloadData()
    }
    
    func onEventsError() {
        self.view.makeToast("Error loading events")
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
        self.currentPage = 1
        loadEvents()
        searchBar.resignFirstResponder()
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
    
    func isSearching() -> Bool {
        return self.searchBar.text.utf16Count > 0
    }
}

