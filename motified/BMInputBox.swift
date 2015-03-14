//
//  BMInputBox.swift
//  BMInputBox
//
//  Created by Adam Eri on 10/02/2015.
//  Copyright (c) 2015 blackmirror media. All rights reserved.
//

import UIKit

class BMInputBox: UIView {

    enum BMInputBoxStyle {
        case PlainTextInput         // Simple text field
        case NumberInput            // Text field accepting numbers only - numeric keyboard
        case PhoneNumberInput       // Text field accepting numbers only - phone keyboard
        case EmailInput             // Text field accepting email addresses -  email keyboard
        case SecureTextInput        // Secure text field for passwords
        case LoginAndPasswordInput  // Two text fields for user and password entry
        case DatePickerInput        // Date picker
        case PickerInput            // Value picker
    }


    // MARK: Initializers

    /// Title of the box
    var title: NSString?

    /// Message in the box
    var message: NSString?

    /// Text on submit button
    var submitButtonText: NSString?

    /// Text on cancel button
    var cancelButtonText: NSString?

    /// The current style of the box
    var style: BMInputBoxStyle = .PlainTextInput

    /// The amount of mandatory decimals in case of Number input
    var numberOfDecimals: Int = 0

    /// Array holding all elements in the view.
    var elements = NSMutableArray()

    /// Visual effect style
    var blurEffectStyle: UIBlurEffectStyle?

    /// Visual effects view holding the content
    private var visualEffectView: UIVisualEffectView?


    /**
    Class method creating an instace of the input box with a specific style. See BMInputBoxStyle for available styles. Every style comes with different kind and number of input types.

    :param: style Style of the input box

    :returns: instance of the input box.
    */
    class func boxWithStyle (style: BMInputBoxStyle) -> BMInputBox {
        let window = UIApplication.sharedApplication().windows.first as UIWindow

        let boxFrame = CGRectMake(0, 0, min(325, window.frame.size.width - 50), 210)

        var inputBox = BMInputBox(frame: boxFrame)
        inputBox.center = CGPointMake(window.center.x, window.center.y - 30)
        inputBox.style = style
        return inputBox
    }


    // MARK: Showing and hiding the box

    /**
    Shows the input box
    */
    func show () {

        self.alpha = 0
        self.setupView()

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 1
            })

        let window = UIApplication.sharedApplication().windows.first as UIWindow
        window.addSubview(self)
        window.bringSubviewToFront(self)

        // Rotation support
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange", name: UIDeviceOrientationDidChangeNotification, object: nil)

        // Keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil)
    }

    /**
    Hides the input box
    */
    func hide () {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 0
        }) { (completed) -> Void in
            self.removeFromSuperview()

            // Rotation support
            UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)

            // Keyboard
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        }
    }

    /**
    Method called when creating the box. Sets up the user elements based on the style and the possible custom elements.
    */
    private func setupView () {

        /// Corners
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true

        /// Blur stuff
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: self.blurEffectStyle? ?? UIBlurEffectStyle.ExtraLight))

        /// Constants
        let padding: CGFloat = 20.0
        let width = self.frame.size.width - padding * 2

        /// Labels
        var titleLabel = UILabel(frame: CGRectMake(padding, padding, width, 20))
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        titleLabel.text = self.title?
        titleLabel.textAlignment = .Center
        titleLabel.textColor = (self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor()
        self.visualEffectView?.contentView.addSubview(titleLabel)

        var messageLabel = UILabel(frame: CGRectMake(padding, padding + titleLabel.frame.size.height + 10, width, 20))
        messageLabel.numberOfLines = 4;
        messageLabel.font = UIFont.systemFontOfSize(14)
        messageLabel.text = self.message?
        messageLabel.textAlignment = .Center
        messageLabel.textColor = (self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor()
        messageLabel.sizeToFit()
        self.visualEffectView?.contentView.addSubview(messageLabel)


        /**
        *  Inputs
        */
        switch self.style {
        case .PlainTextInput, .NumberInput, .EmailInput, .SecureTextInput, .PhoneNumberInput:
            self.textInput = UITextField(frame: CGRectMake(padding, messageLabel.frame.origin.y + messageLabel.frame.size.height + padding / 1.5, width, 35))
            self.textInput?.textAlignment = .Center

            // Allow customisation
            if self.customiseInputElement != nil {
                self.textInput = self.customiseInputElement(element: self.textInput!)
            }

            self.elements.addObject(self.textInput!)

        case .LoginAndPasswordInput:

            // TextField

            self.textInput = UITextField(frame: CGRectMake(padding, messageLabel.frame.origin.y + messageLabel.frame.size.height + padding / 1.5, width, 35))
            self.textInput?.textAlignment = .Center

            // Allow customisation
            if self.customiseInputElement != nil {
                self.textInput = self.customiseInputElement(element: self.textInput!)
            }

            self.elements.addObject(self.textInput!)

            // PasswordField
            self.secureInput = UITextField(frame: CGRectMake(padding, self.textInput!.frame.origin.y + self.textInput!.frame.size.height + padding / 2, width, 35))
            self.secureInput?.textAlignment = .Center
            self.secureInput?.secureTextEntry = true

            // Allow customisation
            if self.customiseInputElement != nil {
                self.secureInput = self.customiseInputElement(element: self.secureInput!)
            }

            self.elements.addObject(self.secureInput!)

            var extendedFrame = self.frame
            extendedFrame.size.height += 45
            self.frame = extendedFrame

            //  TODO: Finish
            //        case .DatePickerInput:
            //
            //        case .PickerInput:

        default:
            NSLog("nothing here")
        }

        if self.style == .NumberInput {
            self.textInput?.keyboardType = .NumberPad
            self.textInput?.addTarget(self, action: "textInputDidChange", forControlEvents: .EditingChanged)
        }

        if self.style == .PhoneNumberInput {
            self.textInput?.keyboardType = .PhonePad
        }

        if self.style == .EmailInput {
            self.textInput?.keyboardType = .EmailAddress
        }

        if self.style == .SecureTextInput {
            self.textInput?.secureTextEntry = true
        }

        for element in self.elements {
            let element: UITextField = element as UITextField
            element.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
            element.layer.borderWidth = 0.5
            element.backgroundColor = (self.blurEffectStyle == .Dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.5)
            self.visualEffectView?.contentView.addSubview(element)
        }


        /**
        *  Setting up buttons
        */

        let buttonHeight: CGFloat = 45.0
        let buttonWidth = self.frame.size.width / 2

        var cancelButton = UIButton(frame: CGRectMake(0, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight))
        cancelButton.setTitle(self.cancelButtonText? ?? "Cancel", forState: .Normal)
        cancelButton.addTarget(self, action: "cancelButtonTapped", forControlEvents: .TouchUpInside)
        cancelButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        cancelButton.setTitleColor((self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor(), forState: .Normal)
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        cancelButton.backgroundColor = (self.blurEffectStyle == .Dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.2)
        cancelButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
        cancelButton.layer.borderWidth = 0.5
        self.visualEffectView?.contentView.addSubview(cancelButton)

        var submitButton = UIButton(frame: CGRectMake(buttonWidth, self.frame.size.height - buttonHeight, buttonWidth, buttonHeight))
        submitButton.setTitle(self.submitButtonText? ?? "OK", forState: .Normal)
        submitButton.addTarget(self, action: "submitButtonTapped", forControlEvents: .TouchUpInside)
        submitButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        submitButton.setTitleColor((self.blurEffectStyle == .Dark) ? UIColor.whiteColor() : UIColor.blackColor(), forState: .Normal)
        submitButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        submitButton.backgroundColor = (self.blurEffectStyle == .Dark) ? UIColor(white: 1, alpha: 0.07) : UIColor(white: 1, alpha: 0.2)
        submitButton.layer.borderColor = UIColor(white: 0, alpha: 0.1).CGColor
        submitButton.layer.borderWidth = 0.5
        self.visualEffectView?.contentView.addSubview(submitButton)


        /**
        Adding the visual effects view.
        */
        self.visualEffectView!.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        self.addSubview(self.visualEffectView!)
    }

    internal func deviceOrientationDidChange () {
        self.resetFrame(true)
    }

    // MARK: Handling user input and actions

    /// Text input used in styles: PlainTextInput, NumberInput, PhoneNumberInput, EmailInput and as a first input in LoginAndPasswordInput.
    private var textInput: UITextField?

    /// Text input used in SecureTextInput and as a second input in LoginAndPasswordInput.
    private var secureInput: UITextField?

    /// Elemenet used in datePicker style.
    private var datePicker: UIDatePicker?

    /// Elemenet used in picker style.
    var picker: UIPickerView?

    /// Closure to allow customisation of the input element
    var customiseInputElement: ((element: UITextField) -> UITextField)!

    /// Closure executed when user submits the values.
    var onSubmit: ((value: AnyObject...) -> Void)!

    /// Closure executed when user cancels submission
    var onCancel: (() -> Void)!

    internal func cancelButtonTapped () {
        if self.onCancel != nil {
            self.onCancel()
        }
        self.hide()
    }

    internal func submitButtonTapped () {
        if self.onSubmit != nil {
            let valueToReturn: String? = self.textInput!.text

            if let value2ToReturn = self.secureInput?.text {
                self.onSubmit(value: valueToReturn!, value2ToReturn)
            }
            else {
                self.onSubmit(value: valueToReturn!)
            }
        }
        self.hide()
    }

    internal func textInputDidChange () {
        var text: NSString = self.textInput!.text as NSString
        text = text.stringByReplacingOccurrencesOfString(".", withString: "")

        let power = pow(10.0, Double(self.numberOfDecimals))
        let number: Double = text.doubleValue / Double(power)
        let formatter = "%." + NSString(format: "%i", self.numberOfDecimals) + "lf"

        let formattedString = NSString(format: formatter, number)
        self.textInput?.text = formattedString
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.endEditing(true)
    }

    // MARK: Keyboard Changes

    internal func keyboardDidShow (notification: NSNotification) {
        self.resetFrame(true)

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var frame = self.frame
            frame.origin.y -= self.yCorrection()
            self.frame = frame
        })
    }

    internal func keyboardDidHide (notification: NSNotification) {
        self.resetFrame(true)
    }

    private func yCorrection () -> CGFloat {

        var yCorrection: CGFloat = 30.0

        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                yCorrection = 60.0
            }
            else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                yCorrection = 100.0
            }

            if self.style == .LoginAndPasswordInput {
                yCorrection += 45.0
            }

        }
        else {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                yCorrection = 0.0
            }
        }
        return yCorrection
    }

    private func resetFrame (animated: Bool) {
        var topMargin: CGFloat = (self.style == .LoginAndPasswordInput) ? 0.0 : 45.0
        let window = UIApplication.sharedApplication().windows.first as UIWindow


        if animated {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.center = CGPointMake(window.center.x, window.center.y - topMargin)
            })
        }
        else {
            self.center = CGPointMake(window.center.x, window.center.y - topMargin)
        }
    }
}
