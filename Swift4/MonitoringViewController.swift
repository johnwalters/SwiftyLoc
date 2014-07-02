//
//  MonitoringViewController.swift
//  Swift4
//
//  Created by John Walters on 6/29/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

import UIKit
import CoreLocation;
import CoreBluetooth;

class MonitoringViewController : UITableViewController, CLLocationManagerDelegate {
    var uuid:NSUUID = NSUUID(UUIDString: "")
    var enabled:Bool=false;
    var major:NSNumber=0
    var minor:NSNumber=0
    var notifyOnEntry = false
    var notifyOnExit = false
    var notifyOnDisplay = false

    var locationManager: CLLocationManager?
    var numberFormatter = NSNumberFormatter()
    
    var doneButton: UIBarButtonItem?
    
    
    @IBOutlet var enabledSwitch: UISwitch
    @IBOutlet var notifyOnEntrySwitch: UISwitch
    @IBOutlet var notifyOnExitSwitch: UISwitch
    @IBOutlet var notifyOnDisplaySwitch: UISwitch
    @IBOutlet var majorTextField: UITextField
    @IBOutlet var uuidTextField: UITextField
    @IBOutlet var minorTextField: UITextField
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager!.delegate = self;

        numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle

        var region = CLBeaconRegion(proximityUUID: NSUUID.UUID(), identifier: Defaults.sharedDefaults().BeaconIdentifier)
        region = locationManager!.monitoredRegions.member(region) as CLBeaconRegion
        if(region != nil){
            enabled = true;
            uuid = region.proximityUUID;
            major = region.major;
            majorTextField.text = major.stringValue
            minor = region.minor;
            minorTextField.text = minor.stringValue
            notifyOnEntry = region.notifyOnEntry;
            notifyOnExit = region.notifyOnExit;
            notifyOnDisplay = region.notifyEntryStateOnDisplay;
        } else {
            enabled = false;
            uuid = Defaults.sharedDefaults().defaultProximityUUID()
            major = 0
            minor = 0;
            notifyOnEntry = true
            notifyOnExit = true;
            notifyOnDisplay = false;
        }

        doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneEditing:")
      
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        uuidTextField.text = uuid.UUIDString
        
        
    }

    @IBAction func unwindUUIDSelector(sender: UIStoryboardSegue) {
        var uuidSelector : UUIDViewController = sender.sourceViewController as UUIDViewController
            self.uuid = uuidSelector.uuid!
        updateMonitoredRegion()
    }
    
    func updateMonitoredRegion() {
        var region:CLBeaconRegion = CLBeaconRegion(proximityUUID: NSUUID.UUID(), identifier: Defaults.sharedDefaults().BeaconIdentifier)
        if region != nil {
            locationManager?.stopMonitoringForRegion(region)
        }
        if enabled {
            
            if(uuid != nil && major != 0 && minor != 0){
                var maj: UInt16 = UInt16(major.intValue)
                var min: UInt16 = UInt16(minor.intValue)
                region = CLBeaconRegion(proximityUUID: NSUUID.UUID(), major:maj, minor:min,identifier: Defaults.sharedDefaults().BeaconIdentifier)
            } else if (uuid != nil && major != 0 ) {
                var maj: UInt16 = UInt16(major.intValue)
                region = CLBeaconRegion(proximityUUID: NSUUID.UUID(), major:maj, identifier: Defaults.sharedDefaults().BeaconIdentifier)
            } else if (uuid != nil ) {
                region = CLBeaconRegion(proximityUUID: NSUUID.UUID(), identifier: Defaults.sharedDefaults().BeaconIdentifier)
            }

        }
        if region != nil {
            region.notifyOnEntry = self.notifyOnEntry;
            region.notifyOnExit = self.notifyOnExit;
            region.notifyEntryStateOnDisplay = self.notifyOnDisplay;
            locationManager?.startMonitoringForRegion(region)
        }
    }
    
}
