//
//  CalibrationEndViewController.swift
//  Swift4
//
//  Created by John Walters on 7/12/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

import UIKit

class CalibrationEndViewController: UIViewController {
    
    var measuredPower:NSInteger = 0
    
    @IBOutlet var measuredPowerLabel: UILabel!
    
    func doneButtonTapped(sender:AnyObject) {
        // [self.navigationController popToRootViewControllerAnimated:YES];
        navigationController.popToRootViewControllerAnimated(true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        var doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneButtonTapped:")
        navigationItem.rightBarButtonItem = doneButton
        measuredPowerLabel.text = NSString(format: "%ld", self.measuredPower)
        
    }
    

    func setMeasuredPower(measuredPower:NSInteger) {
        self.measuredPower = measuredPower
        measuredPowerLabel.text = NSString(format: "%ld", measuredPower)
    }
}