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
    
    @IBOutlet weak var onStartSwitch: UISwitch!
    @IBOutlet weak var hourPriorSwitch: UISwitch!
    @IBOutlet weak var dayPriorSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBorder(self.logoutBtn)
        addBorder(self.contactBtn)
        addBorder(self.agreementBtn)
        addBorder(self.aboutBtn)
        
        self.onStartSwitch.setOn(UserPreferenceManager.shouldAlert(PREF_ON_START_KEY), animated: false)
        self.hourPriorSwitch.setOn(UserPreferenceManager.shouldAlert(PREF_HOUR_PRIOR_KEY), animated: false)
        self.dayPriorSwitch.setOn(UserPreferenceManager.shouldAlert(PREF_DAY_PRIOR_KEY), animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_ID_LOGOUT {
            let dest = segue.destinationViewController as AuthManagingViewController
            dest.shouldLogIn = false
        }
    }
    
    @IBAction func onEventStartSwitchPressed(sender: UISwitch) {
        UserPreferenceManager.setAlert(PREF_ON_START_KEY, shouldAlert: self.onStartSwitch.on)
    }
    
    @IBAction func onHourSwitchPressed(sender: UISwitch) {
        UserPreferenceManager.setAlert(PREF_HOUR_PRIOR_KEY, shouldAlert: self.hourPriorSwitch.on)
    }
    
    @IBAction func on24HourSwitchPressed(sender: UISwitch) {
        UserPreferenceManager.setAlert(PREF_DAY_PRIOR_KEY, shouldAlert: self.dayPriorSwitch.on)
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        LoginManager.logOut()
        self.performSegueWithIdentifier(SEGUE_ID_LOGOUT, sender: nil)
    }
    
    @IBAction func onContact(sender: AnyObject) {
    }
    
    @IBAction func onAbout(sender: AnyObject) {
    }
    
    @IBAction func onAgreement(sender: AnyObject) {
    }
}

