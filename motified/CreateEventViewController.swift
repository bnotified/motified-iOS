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
    
    let startPicker: UIDatePicker = UIDatePicker()
    let endPicker: UIDatePicker = UIDatePicker()
    let categoryPicker: UIPickerView = UIPickerView()
    let localFormatter = MotifiedDateFormatter(format: MotifiedDateFormat.ClientLong)
    
    let categories = APIManager.sharedInstance.categories
    var selectedCategory: String!
    
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
        
        // Set up input views
        self.startLabel.inputView = self.startPicker
        self.endLabel.inputView = self.endPicker
        self.categoryLabel.inputView = self.categoryPicker

        // Set up targets
        self.startPicker.addTarget(self, action: "updateStartLabel", forControlEvents: UIControlEvents.ValueChanged)
        self.startPicker.addTarget(self, action: "updateStartLabel", forControlEvents: UIControlEvents.EditingDidBegin)
        self.endPicker.addTarget(self, action: "updateEndLabel", forControlEvents: UIControlEvents.EditingDidBegin)
        self.endPicker.addTarget(self, action: "updateEndLabel", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func updateStartLabel() {
        self.startLabel.text = self.localFormatter.stringFromDate(self.startPicker.date)
        self.endPicker.minimumDate = self.startPicker.date
    }
    
    func updateEndLabel() {
        self.endLabel.text = self.localFormatter.stringFromDate(self.endPicker.date)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        if textField == self.titleLabel {
            self.descriptionTextEdit.becomeFirstResponder()
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
    
    @IBAction func onSubmit(sender: AnyObject) {
        let serverFormatter = MotifiedDateFormatter(format: MotifiedDateFormat.Server)
        let params = [
            "name": self.titleLabel.text,
            "description": self.descriptionTextEdit.text,
            "start": serverFormatter.stringFromDate(self.startPicker.date),
            "end": serverFormatter.stringFromDate(self.endPicker.date),
            "categories": [
                ["category": self.selectedCategory]
            ]
        ]
        
        NSLog("Will Submit Params: %@", params)
    }
}
