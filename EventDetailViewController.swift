//
//  EventDetailViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/25/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit
import MapKit

class EventDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var openBtn: UIButton!
    @IBOutlet weak var beNotifiedBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    
    var event: Event!
    var mapItem: MKMapItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.event == nil {
            self.handleNoEvent()
        } else {
            self.setUp()
        }
    }
    
    func setUp() {
        self.setUpMap()
        if self.event.isSubscribed == true {
            self.beNotifiedBtn.titleLabel?.text = "Unsubscribe"
        } else {
            self.beNotifiedBtn.titleLabel?.text = "Be Notified"
        }
        
        self.titleLabel.text = event.title
        self.dateLabel.text = event.getFormattedDateRange()
        self.descriptionLabel.text = event.desc
        
        addBorderMatchingBackground(self.openBtn)
        addBorderMatchingBackground(self.beNotifiedBtn)
        addBorderMatchingBackground(self.reportBtn)
    }
    
    func setUpMap() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = self.event.address! + ", Michigan"
        let map = self.mapView
        request.region = map.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.startWithCompletionHandler { (MKLocalSearchResponse, NSError) -> Void in
            if NSError != nil {
                NSLog("Error: %@", NSError)
                return ()
            }
            if MKLocalSearchResponse.mapItems.count == 0 {
                self.view.makeToast("No results")
                return ()
            }
            let items = MKLocalSearchResponse.mapItems as [MKMapItem]
            NSLog("Items: %@", items)
            let first: MKMapItem = items.first!
            map.addAnnotation(first.placemark)
            map.showAnnotations(map.annotations, animated: true)
            self.mapItem = first
        }
    }
    
    func handleNoEvent() {
        self.view.makeToast("Error: No event loaded")
        delay(2, { () -> () in
            self.navigationController?.popViewControllerAnimated(true)
            return ()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onOpenPressed(sender: AnyObject) {
        if self.mapItem == nil {
            self.view.makeToast("Please wait for the map to finish loading")
            return ()
        }

        let options = []
        self.mapItem.openInMapsWithLaunchOptions(nil)
        
    }
    
    @IBAction func onNotifyPressed(sender: AnyObject) {
        
    }
    
    @IBAction func onReportPressed(sender: AnyObject) {
        
    }
}
