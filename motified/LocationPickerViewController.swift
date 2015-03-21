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
    
    let defaultLocations: Array<Dictionary<String, AnyObject!>> = [
        [
            "title": "The Neutral Zone, Ann Arbor, Michigan",
            "annotation": nil
        ],
        [
            "title": "Zingerman's Bakehouse, Ann Arbor, Michigan",
            "annotation": nil
        ],
        [
            "title": "The Michigan Theater, Ann Arbor, Michigan",
            "annotation": nil
        ],
        [
            "title": "The Yellow Barn, Ann Arbor, Michigan",
            "annotation": nil
        ],
        [
            "title": "Washtenaw Community College, Ann Arbor, Michigan",
            "annotation": nil
        ]
    ]
    
    var searchResults: Array<Dictionary<String, AnyObject!>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up delegates
        self.locationPickerView.tableViewDataSource = self
        self.locationPickerView.tableViewDelegate = self
        self.locationPickerView.defaultMapHeight = self.locationPickerView.defaultMapHeight + 20
        
        // Optional setup
        self.locationPickerView.shouldCreateHideMapButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSearch(sender: AnyObject) {
        self.makeRequest()
    }
    
    func makeRequest() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        let map = self.locationPickerView.mapView
        request.region = map.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.startWithCompletionHandler { (MKLocalSearchResponse, NSError) -> Void in
            if NSError != nil {
                self.view.makeToast(NSString(format: "Error: %@", NSError))
                return ()
            }
            if MKLocalSearchResponse.mapItems.count == 0 {
                self.view.makeToast("No results")
                return ()
            }
            let items = MKLocalSearchResponse.mapItems as [MKMapItem]
            self.updateSearchResults(items)
            self.updateAnnotations(items)
        }
    }
    
    func updateSearchResults(mapItems: Array<MKMapItem>) {
        self.searchResults.removeAll(keepCapacity: true)
        for item in mapItems {
            self.searchResults.append([
                "title": item.name,
                "annotation": item.placemark
            ])
        }
        self.locationPickerView.tableView.reloadData()
    }
    
    func updateAnnotations(mapItems: Array<MKMapItem>) {
        let map = self.locationPickerView.mapView
        for item in mapItems as [MKMapItem] {
            for annotation in map.annotations as [MKAnnotation] {
                if(annotation.coordinate.latitude == item.placemark.coordinate.latitude &&
                    annotation.coordinate.longitude == item.placemark.coordinate.longitude) {
                        return ()
                }
            }
            map.addAnnotation(item.placemark)
        }
        self.showAnnotations()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "location_cell_identifier"
        let data = self.getDataForRow(indexPath.row)
        
        let title = data["title"]! as String
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
        cell.textLabel?.text = title
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hasSearchResults() {
            return max(self.searchResults.count, 5)
        }
        return self.defaultLocations.count
    }
    
    internal func hasSearchResults() -> Bool {
        return self.searchResults.count > 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func getDataForRow(row: Int) -> Dictionary<String, AnyObject!> {
        if self.hasSearchResults() {
            if self.searchResults.count > row {
                return self.searchResults[row]
            }
            // Necessary so tableview doesn't look weird
            return [
                "title": "",
                "annotation": nil
            ]
        }
        return self.defaultLocations[row]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = self.getDataForRow(indexPath.row)
        let map = self.locationPickerView.mapView
        self.clearAnnotations()
        if let annotation = data["annotation"] as? MKAnnotation {
            map.addAnnotation(annotation)
            self.showAnnotations()
        }
    }
    
    internal func showAnnotations() {
        let map = self.locationPickerView.mapView
        map.showAnnotations(map.annotations, animated: true)
    }
    
    internal func clearAnnotations() {
        self.locationPickerView.mapView.removeAnnotations(self.locationPickerView.mapView.annotations)
    }
}
