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
    
    var event: Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.event == nil {
            self.handleNoEvent()
        } else {
            self.setUp()
        }
    }
    
    func setUp() {
        self.titleLabel.text = event.title
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
        
    }
    
    @IBAction func onNotifyPressed(sender: AnyObject) {
        
    }
}
