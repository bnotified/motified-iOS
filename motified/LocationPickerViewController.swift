//
//  LocationPickerViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/20/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class LocationPickerViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, LocationPickerViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationPickerView: LocationPickerView!
    
    var defaultLocations: Array<Dictionary<String, AnyObject!>> = [
        [
            "title": "The Neutral Zone",
            "display": "The Neutral Zone",
            "right": "",
            "annotation": nil
        ],
        [
            "title": "Zingerman's Bakehouse",
            "display": "Zingerman's Bakehouse",
            "right": "",
            "annotation": nil
        ],
        [
            "title": "The Michigan Theater",
            "display": "The Michigan Theater",
            "right": "",
            "annotation": nil
        ],
        [
            "title": "The Yellow Barn",
            "display": "The Yellow Barn",
            "right": "",
            "annotation": nil
        ],
        [
            "title": "Washtenaw Community College",
            "display": "Washtenaw Community College",
            "right": "",
            "annotation": nil
        ]
    ]
    
    var searchResults: Array<Dictionary<String, AnyObject!>> = []
    var selectedLocation: Dictionary<String, AnyObject!>! = nil
    var debouncedSearch: (()->())? = nil
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        // Set up delegates
        self.locationPickerView.delegate = self
        self.locationPickerView.tableViewDataSource = self
        self.locationPickerView.tableViewDelegate = self
        self.locationPickerView.defaultMapHeight = self.locationPickerView.defaultMapHeight + 20
        
        self.searchBar.delegate = self
        
        // Optional setup
        self.locationPickerView.shouldCreateHideMapButton = true
        
        self.debouncedSearch = debounce(NSTimeInterval(0.25), dispatch_get_main_queue(), self.makeRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard() {
        NSLog("Should hide keyboard")
        self.view.endEditing(true)
    }
    
    func makeRequest() {
        if self.searchBar.text.utf16Count == 0 {
            return ()
        }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = self.searchBar.text + "Ann Arbor, Michigan, United States"
        let map = self.locationPickerView.mapView
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
            self.clearAnnotations()
            self.updateSearchResults(items)
            self.updateAnnotations(items)
        }
    }
    
    func centerOnAnnArbor() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Ann Arbor Michigan"
        let map = self.locationPickerView.mapView
        request.region = map.region
        let localSearch = MKLocalSearch(request: request)
        localSearch.startWithCompletionHandler { (MKLocalSearchResponse, NSError) -> Void in
            if NSError != nil {
                NSLog("Error: %@", NSError)
                return ()
            }
            if MKLocalSearchResponse.mapItems.count == 0 {
                return ()
            }
            let items = MKLocalSearchResponse.mapItems as [MKMapItem]
            let placemark = items.first!.placemark
            map.showAnnotations([placemark], animated: false)
            map.region.span.longitudeDelta = 0.05
            map.region.span.latitudeDelta = 0.05
            map.removeAnnotation(placemark)
        }
    }
    
    internal func loadDefaultPlacemarks() {
        for x in 0...self.defaultLocations.count - 1 {
            self.loadPlacemarkForDefaultAtIndex(x)
        }
    }
    
    internal func loadPlacemarkForDefaultAtIndex(index: Int) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = self.defaultLocations[index]["title"]! as String + " Ann Arbor, Michigan"
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
            let item = items.first!
            let placemark = item.placemark as MKPlacemark
            let address = self.getFormattedAddress(item)
            let right = self.getName(item)
            self.defaultLocations[index].updateValue(placemark, forKey: "annotation")
            self.defaultLocations[index].updateValue(address, forKey: "title")
            self.defaultLocations[index].updateValue(right, forKey: "right")
            self.locationPickerView.tableView.reloadData()
        }
    }
    
    internal func getFormattedAddress(item: MKMapItem) -> String {
        let placemark = item.placemark
        let number = placemark.subThoroughfare ?? ""
        let address = placemark.thoroughfare ?? ""
        let postal = placemark.postalCode ?? ""
        let locality = placemark.locality ?? ""
        
        return "\(number) \(address)\n\(postal) \(locality)"
    }
    
    internal func getName(item: MKMapItem) -> String {
        let placemark = item.placemark
        if let street: AnyObject = placemark.addressDictionary["Street"] {
            if let st = street as? String {
                if placemark.name == st {
                    return ""
                }
            }
        }
        return placemark.name
    }
    
    func updateSearchResults(mapItems: Array<MKMapItem>) {
        self.searchResults.removeAll(keepCapacity: true)
        for item in mapItems {
            let title = self.getFormattedAddress(item)
            let right = self.getName(item)
            let display = (right == "") ? title : right
            
            self.searchResults.append([
                "title": title,
                "right": right,
                "display": display,
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
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier)
        
        let title = data["title"]! as String
        if let right: AnyObject! = data["right"] {
            if let rt = right as? String {
                cell.detailTextLabel?.text = rt
            }
        }

        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = title
        
        cell.detailTextLabel?.numberOfLines = 0

        
        
        cell.textLabel?.sizeToFit()
        cell.detailTextLabel?.sizeToFit()
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let label = UILabel()
        let data = self.getDataForRow(indexPath.row)
        label.numberOfLines = 0
        if let right: AnyObject! = data["right"] {
            if let rt = right as? String {
                label.text = rt
            } else {
                return 50
            }
        } else {
            return 50
        }
        let constraints = CGSizeMake(self.view.frame.width / 2, CGFloat.max)
        let sizeToFit2 = label.sizeThatFits(constraints)
        
        return max(50, sizeToFit2.height + 20)
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
        self.hideKeyboard()
        let data = self.getDataForRow(indexPath.row)
        let map = self.locationPickerView.mapView
        self.clearAnnotations()
        if let annotation = data["annotation"] as? MKAnnotation {
            map.addAnnotation(annotation)
            self.showAnnotations()
        }
        self.selectedLocation = data
        self.updateBackButton()
    }
    
    internal func updateBackButton() {
        if self.selectedLocation != nil {
            self.navigationItem.leftBarButtonItem?.title = "Done"
        } else {
            self.navigationItem.leftBarButtonItem?.title = "Cancel"
        }
    }
    
    internal func showAnnotations() {
        let map = self.locationPickerView.mapView
        map.showAnnotations(map.annotations, animated: false)
        let center = map.centerCoordinate
        let newCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: center.latitude - map.region.span.latitudeDelta * 0.20, longitude: center.longitude)
        map.setCenterCoordinate(newCenter, animated: true)
    }
    
    func myMKMapRect(x: Double, y:Double, w:Double, h:Double) -> MKMapRect {
        return MKMapRect(origin:MKMapPoint(x:x, y:y), size:MKMapSize(width:w, height:h))
    }
    
    internal func clearAnnotations() {
        self.locationPickerView.mapView.removeAnnotations(self.locationPickerView.mapView.annotations)
    }
    
    func locationPicker(locationPicker: LocationPickerView!, mapViewDidLoad mapView: MKMapView!) {
        self.loadDefaultPlacemarks()
        self.centerOnAnnArbor()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.debouncedSearch!()
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        let notification = NSNotification(name: NOTIFICATION_LOCATION_PICKED, object: nil, userInfo: self.selectedLocation)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func locationPicker(locationPicker: LocationPickerView!, mapViewWillExpand mapView: MKMapView!) {
        self.hideKeyboard()
    }
    
    
}
