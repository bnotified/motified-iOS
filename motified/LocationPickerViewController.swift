//
//  LocationPickerViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/20/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit
import MapKit

class LocationPickerViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        request.region = self.map.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.startWithCompletionHandler { (MKLocalSearchResponse, NSError) -> Void in
            if NSError != nil {
                NSLog("Error: %@", NSError);
                return ()
            }
            if MKLocalSearchResponse.mapItems.count == 0 {
                NSLog("No Results")
                return ()
            }
            for item in MKLocalSearchResponse.mapItems as [MKMapItem] {
                for annotation in self.map.annotations as [MKAnnotation] {
                    if(annotation.coordinate.latitude == item.placemark.coordinate.latitude &&
                        annotation.coordinate.longitude == item.placemark.coordinate.longitude) {
                            return ()
                    }
                }
                self.map.addAnnotation(item.placemark)
            }
        }
    }
}
