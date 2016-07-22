//
//  ViewController.swift
//  AutoCompleteTextField
//
//  Created by Neil Francis Ramirez Hipona on 03/19/2016.
//  Copyright (c) 2016 Neil Francis Ramirez Hipona. All rights reserved.
//

import UIKit
import AutoCompleteTextField


class ViewController: UIViewController, AutoCompleteTextFieldDataSource, AutoCompleteTextFieldDelegate {
    
    @IBOutlet weak var autoCompleteTextField: AutoCompleteTextField!
    @IBOutlet weak var autoCompleteTextFieldWithDelimiter: AutoCompleteTextField!
    
    let domainNames = ["gmail.com",
                       "yahoo.com",
                       "hotmail.com",
                       "aol.com",
                       "comcast.net",
                       "me.com",
                       "msn.com",
                       "live.com",
                       "sbcglobal.net",
                       "ymail.com",
                       "icloud.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Optional setting for delegate if not setted in IB
        autoCompleteTextFieldWithDelimiter.autoCompleteTextFieldDataSource = self
        autoCompleteTextFieldWithDelimiter.setDelimiter("@")
        autoCompleteTextFieldWithDelimiter.autoCompleteTextFieldDelegate = self
        
        // Show right side complete button
        autoCompleteTextField.showAutoCompleteButton(autoCompleteButtonViewMode: .WhileEditing)
        
        // Initializing with datasource and delegate
        let textFieldWithDelegateAndDataSource = AutoCompleteTextField(frame: CGRect(x: 20, y: 64, width: view.frame.width - 40, height: 40), autoCompleteTextFieldDataSource: self)
        textFieldWithDelegateAndDataSource.backgroundColor = .redColor()
        view.addSubview(textFieldWithDelegateAndDataSource)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - AutoCompleteTextFieldDataSource
    
    func autoCompleteTextFieldDataSource(autoCompleteTextField: AutoCompleteTextField) -> [String] {
        
        return domainNames
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {

        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        print("tf: \(textField.text!) \(string)")
        
        return true
    }
}

