//
//  CreateEventViewController.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/16/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate  {

    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var descriptionTextEdit: UITextView!
    @IBOutlet weak var endLabel: UITextField!
    @IBOutlet weak var startLabel: UITextField!
    @IBOutlet weak var categoryLabel: UITextField!
    @IBOutlet weak var locationLabel: UITextField!
    
    let startPicker: UIDatePicker = UIDatePicker()
    let endPicker: UIDatePicker = UIDatePicker()
    let categoryPicker: UIPickerView = UIPickerView()
    let localFormatter = MotifiedDateFormatter(format: MotifiedDateFormat.ClientLong)
    
    let categories = APIManager.sharedInstance.categories
    var selectedCategory: String!
    var selectedLocation: Dictionary<String, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up delegates
        self.titleLabel.delegate = self
        self.descriptionTextEdit.delegate = self
        self.endLabel.delegate = self
        self.startLabel.delegate = self
        self.categoryLabel.delegate = self
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        self.locationLabel.delegate = self
        
        // Set up input views
        self.startLabel.inputView = self.startPicker
        self.endLabel.inputView = self.endPicker
        self.categoryLabel.inputView = self.categoryPicker

        // Set up targets
        self.startPicker.addTarget(self, action: "updateStartLabel", forControlEvents: UIControlEvents.ValueChanged)
        self.startPicker.addTarget(self, action: "updateStartLabel", forControlEvents: UIControlEvents.EditingDidBegin)
        self.endPicker.addTarget(self, action: "updateEndLabel", forControlEvents: UIControlEvents.EditingDidBegin)
        self.endPicker.addTarget(self, action: "updateEndLabel", forControlEvents: UIControlEvents.ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateLocation:", name: NOTIFICATION_LOCATION_PICKED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_LOCATION_PICKED, object: nil)
    }
    
    func updateStartLabel() {
        self.startLabel.text = self.localFormatter.stringFromDate(self.startPicker.date)
        self.endPicker.minimumDate = self.startPicker.date
    }
    
    func updateEndLabel() {
        self.endLabel.text = self.localFormatter.stringFromDate(self.endPicker.date)
    }
    
    func updateLocation(aNotification: NSNotification) {
        if let location = aNotification.userInfo as? Dictionary<String, AnyObject> {
            NSLog("Location: %@", location)
            self.selectedLocation = [
                "address": location["title"]! as String,
                "address_name": location["right"]! as String
            ]
            self.updateLocationLabel()
        }
    }
    
    func updateLocationLabel() {
        if self.selectedLocation != nil {
            self.locationLabel.text = self.selectedLocation["display"]! as String
        } else {
            self.locationLabel.text = ""
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == self.locationLabel {
            self.performSegueWithIdentifier(SEGUE_ID_GET_LOCATION, sender: self)
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        if textField == self.titleLabel {
            self.descriptionTextEdit.becomeFirstResponder()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == self.startLabel {
            self.updateStartLabel()
        } else if textField == self.endLabel {
            self.updateEndLabel()
        } else if textField == self.categoryLabel {
            self.selectedCategory = self.categories[0]["category"]! as String
            self.categoryLabel.text = self.selectedCategory
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == "") {
            textView.textColor = UIColor.lightGrayColor()
            textView.text = "Event Description"
        }
        self.startLabel.becomeFirstResponder()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Event Description" {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let categoryString = self.categories[row]["category"]! as String
        let title = NSAttributedString(string: categoryString)
        return title
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSLog("Selected: %@", self.categories[row])
        self.selectedCategory = self.categories[row]["category"]! as String
        self.categoryLabel.text = self.selectedCategory
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categories.count
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func isFormValid() -> Bool {
        return (
            self.isTitleValid() &&
            self.isDescriptionValid() &&
            self.isStartDateValid() &&
            self.isEndDateValid() &&
            self.isLocationValid() &&
            self.isCategoryValid()
        )
    }
    
    internal func isTitleValid() -> Bool {
        return self.titleLabel.text.utf16Count > 0
    }
    
    internal func isDescriptionValid() -> Bool {
        return (
            self.descriptionTextEdit.text.utf16Count > 0 &&
            self.descriptionTextEdit.text != "Event Description"
        )
    }
    
    internal func isStartDateValid() -> Bool {
        return self.startPicker.date.compare(NSDate()) == NSComparisonResult.OrderedDescending
    }
    
    internal func isEndDateValid() -> Bool {
        return self.endPicker.date.compare(self.startPicker.date) == NSComparisonResult.OrderedDescending
    }
    
    internal func isCategoryValid() -> Bool {
        return self.selectedCategory != nil
    }
    
    internal func isLocationValid() -> Bool {
        return self.selectedLocation != nil
    }
    
    @IBAction func onSubmit(sender: AnyObject) {
        let serverFormatter = MotifiedDateFormatter(format: MotifiedDateFormat.Server)
        if self.isFormValid() {
            let params: Dictionary<String, AnyObject> = [
                "name": self.titleLabel.text,
                "description": self.descriptionTextEdit.text,
                "start": serverFormatter.stringFromDate(self.startPicker.date),
                "end": serverFormatter.stringFromDate(self.endPicker.date),
                "categories": [
                    ["category": self.selectedCategory]
                ],
                "address": self.selectedLocation["address"]! as String,
                "address_name": self.selectedLocation["display"]! as String
            ]
            
            NSLog("Will Submit Params: %@", params)
        } else {
            self.view.makeToast("Please ensure you have filled out all the fields correctly.")
        }
    }
}
