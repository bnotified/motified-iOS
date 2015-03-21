//
//  LocationPickerViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/20/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit
import MapKit

class LocationPickerViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationPickerView: LocationPickerView!
    
    let defaultLocations = [
        "The Neutral Zone, Ann Arbor, Michigan",
        "Zingerman's Bakehouse, Ann Arbor, Michigan",
        "The Michigan Theater, Ann Arbor, Michigan",
        "The Yellow Barn, Ann Arbor, Michigan",
        "Washtenaw Community College, Ann Arbor, Michigan"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up delegates
        self.locationPickerView.tableViewDataSource = self
        self.locationPickerView.tableViewDelegate = self
        
        // Optional setup
        self.locationPickerView.shouldCreateHideMapButton = true
        
//        let oldFrame = self.locationPickerView.frame
//        self.locationPickerView.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y + self.searchBar.frame.height, oldFrame.width, oldFrame.height - self.searchBar.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSearch(sender: AnyObject) {
        //self.makeRequest()
    }
    
//    func makeRequest() {
//        let request = MKLocalSearchRequest()
//        request.naturalLanguageQuery = searchBar.text
//        request.region = self.map.region
//        
//        let localSearch = MKLocalSearch(request: request)
//        localSearch.startWithCompletionHandler { (MKLocalSearchResponse, NSError) -> Void in
//            if NSError != nil {
//                NSLog("Error: %@", NSError);
//                return ()
//            }
//            if MKLocalSearchResponse.mapItems.count == 0 {
//                NSLog("No Results")
//                return ()
//            }
//            for item in MKLocalSearchResponse.mapItems as [MKMapItem] {
//                for annotation in self.map.annotations as [MKAnnotation] {
//                    if(annotation.coordinate.latitude == item.placemark.coordinate.latitude &&
//                        annotation.coordinate.longitude == item.placemark.coordinate.longitude) {
//                            return ()
//                    }
//                }
//                self.map.addAnnotation(item.placemark)
//            }
//        }
//    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "location_cell_identifier"
        let title = self.defaultLocations[indexPath.row]
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
        cell.textLabel?.text = title
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
