//
//  FirstViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class EventFeedViewController: AuthManagingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserPreferenceManager.clearUsernameAndPassword()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

