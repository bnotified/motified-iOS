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
    
    let categories: Array<EventCategory> = APIManager.sharedInstance.categories
    var selectedCategory: EventCategory!
    var selectedLocation: [String: AnyObject]!
    
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
        self.endPicker.setDate(NSDate(timeIntervalSinceNow: self.startPicker.date.timeIntervalSinceNow + 60*60), animated: true)
        self.endPicker.minimumDate = NSDate(timeIntervalSinceNow: self.startPicker.date.timeIntervalSinceNow + 60)
    }
    
    func updateEndLabel() {
        self.endLabel.text = self.localFormatter.stringFromDate(self.endPicker.date)
    }
    
    func updateLocation(aNotification: NSNotification) {
        if let location = aNotification.userInfo as? Dictionary<String, AnyObject> {
            self.selectedLocation = location
            self.updateLocationLabel()
        }
    }
    
    func updateLocationLabel() {
        if self.selectedLocation != nil {
            self.locationLabel.text = self.selectedLocation["display"] as! String
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
        } else if textField == self.categoryLabel && self.categoryLabel.text!.isEmpty {
            print("Setting to zero")
            self.selectedCategory = self.categories[0]
            self.categoryLabel.text = self.selectedCategory.category
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
        let category = self.categories[row]
        let title = NSAttributedString(string: category.category)
        return title
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Updating Selected Category");
        self.selectedCategory = self.categories[row]
        print(self.selectedCategory);
        self.categoryLabel.text = self.selectedCategory.category
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
        return self.titleLabel.text!.characters.count > 0
    }
    
    internal func isDescriptionValid() -> Bool {
        return (
            self.descriptionTextEdit.text.characters.count > 0 &&
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
    
    internal func closeKeyboard() {
        self.titleLabel.resignFirstResponder()
        self.descriptionTextEdit.resignFirstResponder()
        self.startLabel.resignFirstResponder()
        self.endLabel.resignFirstResponder()
        self.locationLabel.resignFirstResponder()
        self.categoryLabel.resignFirstResponder()
    }
    
    @IBAction func onSubmit(sender: AnyObject) {
        let serverFormatter = MotifiedDateFormatter(format: MotifiedDateFormat.Server)
        let categoryId: Int = self.selectedCategory.id
        let categories: [String: Int] = ["id": categoryId]
        let title = self.selectedLocation!["title"] as! String
        let display = self.selectedLocation["display"] as! String

        if self.isFormValid() {
            let params: [String: AnyObject!] = [
                "name": self.titleLabel.text,
                "description": self.descriptionTextEdit.text,
                "start": serverFormatter.stringFromDate(self.startPicker.date),
                "end": serverFormatter.stringFromDate(self.endPicker.date),
                "categories": [categories],
                "address": title,
                "address_name": display,
                "is_reported": 0
            ]
            self.closeKeyboard()
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            APIManager.sharedInstance.addEvent(params, done: { (NSError) -> Void in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                if (NSError != nil) {
                    self.view.makeToast("An error occurred when attempting to create your event.")
                    return ()
                }
                if UserPreferenceManager.isAdmin() {
                    self.view.makeToast("Event Created!", duration: 1.5, position: CSToastPositionCenter)
                    APIManager.sharedInstance.reloadEvents({ (NSError) -> Void in
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        return ()
                    })
                    
                } else {
                    self.view.makeToast("Event Created! Once approved, it will appear on the event feed.", duration: 2.5, position: CSToastPositionCenter)
                    delay(2.5, closure: { () -> () in
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        return ()
                    })
                }
            })
        } else {
            self.view.makeToast("Please ensure you have filled out all the fields correctly.", duration: 3, position: CSToastPositionCenter)
        }
    }
}
