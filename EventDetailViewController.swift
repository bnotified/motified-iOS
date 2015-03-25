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
        if self.event.isSubscribed == true {
            self.navigationItem.rightBarButtonItem?.title = "Unsubscribe"
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Be Notified"
        }
        
        self.titleLabel.text = event.title
        self.dateLabel.text = event.getFormattedDateRange()
        self.descriptionLabel.text = event.desc
        
        self.openBtn.layer.borderWidth = 1.0
        self.openBtn.layer.cornerRadius = 8.0
        self.openBtn.layer.borderColor = UIColor.whiteColor().CGColor
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
