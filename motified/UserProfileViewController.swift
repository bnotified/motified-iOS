//
//  SecondViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/10/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if (indexPath.row == 0) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "reuse1")
            cell.textLabel?.text = "Username:"
            let username = LoginManager.getUsername()
            if (username == "") {
                cell.detailTextLabel?.text = "You are not currently logged in"
            } else {
                cell.detailTextLabel?.text = username
            }
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "reuse2")
            if (indexPath.row == 1) {
                cell.textLabel?.text = "Contact Us"
            } else if (indexPath.row == 2) {
                cell.textLabel?.text = "About Us"
            } else if (indexPath.row == 3) {
                if (LoginManager.isLoggedIn()) {
                    cell.textLabel?.text = "Log Out"
                } else {
                    cell.textLabel?.text = "Log In"
                }
            } else if (indexPath.row == 4) {
                cell.textLabel?.text = "Register"
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (LoginManager.isLoggedIn()) {
            return 4
        }
        return 5
     }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

