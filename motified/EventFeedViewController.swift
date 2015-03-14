//
//  FirstViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class EventFeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let root: QRootElement = QRootElement()
        root.title = "Register"
        //root.controllerName = @"EventFeedViewController"
        root.grouped = true
        
        let section: QSection = QSection()
        let label: QLabelElement = QLabelElement(title: "Username", value: "")
        
        root.addSection(section)
        section.addElement(label)
        
        let nav: UINavigationController = QuickDialogController.controllerWithNavigationForRoot(root)
        self.presentViewController(nav, animated: true, { () -> Void in
            NSLog("Completed")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

