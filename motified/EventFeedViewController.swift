//
//  FirstViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class EventFeedViewController: AuthManagingViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var events: Array<Event> = Array<Event>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "onEventsChanged", name: NOTIFICATION_LOADED_EVENTS, object: nil)
        center.addObserver(self, selector: "onEventsChanged", name: NOTIFICATION_SELECTED_EVENTS_CHANGED, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let manager = APIManager.sharedInstance
        if (manager.hasSelectedCategories()) {
            self.view.makeToast(manager.getSelectedCategoryMessage(), duration: 2, position: CSToastPositionCenter)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let event = sender as Event
        if segue.identifier == SEGUE_ID_EVENT_DETAIL {
            let dest = segue.destinationViewController as EventDetailViewController
            dest.event = event
        }
    }
    
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: NOTIFICATION_LOADED_EVENTS, object: nil)
        center.removeObserver(self, name: NOTIFICATION_SELECTED_EVENTS_CHANGED, object: nil)
    }
    
    func onEventsChanged() {
        self.events = APIManager.sharedInstance.getEventsOnPage(1)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        let event = self.getEventAtIndexPath(indexPath)
        self.performSegueWithIdentifier(SEGUE_ID_EVENT_DETAIL, sender: event)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

