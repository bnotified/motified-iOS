//
//  SecondViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var agreementBtn: UIButton!
    @IBOutlet weak var aboutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBorder(self.logoutBtn)
        addBorder(self.contactBtn)
        addBorder(self.agreementBtn)
        addBorder(self.aboutBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(sender: AnyObject) {
    }
    
    @IBAction func onContact(sender: AnyObject) {
    }
    
    @IBAction func onAbout(sender: AnyObject) {
    }
    
    @IBAction func onAgreement(sender: AnyObject) {
    }
}

