//
//  MonitoringViewController.swift
//  Swift4
//
//  Created by John Walters on 6/29/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

import UIKit

class MonitoringViewController : UITableViewController {
    var uuid:NSUUID = NSUUID(UUIDString: "")
    
    @IBOutlet var enabledSwitch: UISwitch
    @IBOutlet var notifyOnEntrySwitch: UISwitch
    @IBOutlet var notifyOnExitSwitch: UISwitch
    @IBOutlet var notifyOnDisplaySwitch: UISwitch
    @IBOutlet var majorTextField: UITextField
    @IBOutlet var uuidTextField: UITextField
    @IBOutlet var minorTextField: UITextField
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        uuidTextField.text = uuid.UUIDString
        
        
    }

    @IBAction func unwindUUIDSelector(sender: UIStoryboardSegue) {
        var uuidSelector : UUIDViewController = sender.sourceViewController as UUIDViewController
            self.uuid = uuidSelector.uuid!
//        updateAdvertisedRegion()
    }
}
