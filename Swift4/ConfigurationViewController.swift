//
//  ConfigurationViewController.swift
//  Swift4
//
//  Created by John Walters on 6/22/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

import UIKit
import CoreLocation;
import CoreBluetooth;

class ConfigurationViewController: UITableViewController,CBPeripheralManagerDelegate, UITextFieldDelegate {
    
    let _debugMode = true
    var peripheralManager: CBPeripheralManager?;
    var region: CLBeaconRegion?;
    var power:NSNumber?;
    
    @IBOutlet var enabledSwitch: UISwitch
    @IBOutlet weak var majorTextField: UITextField
    @IBOutlet var uuidTextField: UITextField
    @IBOutlet var minorTextField: UITextField
    @IBOutlet var powerTextField: UITextField

    var enabled:Bool=false;
    var uuid:NSUUID = NSUUID(UUIDString: "")
    var major:NSNumber=0
    var minor:NSNumber=0
    
    var doneButton: UIBarButtonItem?
    var numberFormatter:NSNumberFormatter?
    
    override func viewDidLoad(){
        
        super.viewDidLoad()

        doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action:"doneEditing:")
	
        if(region){
            uuid = region!.proximityUUID
            major = region!.major
            minor = region!.minor
            
        }
        else
        {
            uuid = Defaults.sharedDefaults().defaultProximityUUID()
            major = NSNumber.numberWithShort(0)
            minor = NSNumber.numberWithShort(0)
        }

        
        if(!power){
            power = Defaults.sharedDefaults().defaultPower
        }

        numberFormatter = NSNumberFormatter()
        numberFormatter!.numberStyle = NSNumberFormatterStyle.DecimalStyle
    }	
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(peripheralManager == nil){
             peripheralManager = CBPeripheralManager(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0))

            } else {
                peripheralManager!.delegate = self
            }

        enabledSwitch.on = peripheralManager!.isAdvertising
        enabled = enabledSwitch.on
        uuidTextField.text = uuid.UUIDString
        majorTextField.text = major.stringValue
        minorTextField.text = minor.stringValue
        powerTextField.text = power!.stringValue

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        peripheralManager!.delegate = nil
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!){
        
    }
    

    func textfieldShouldBeginEditing(textfield:UITextField) -> Bool{
        if(textfield==self.uuidTextField){
            performSegueWithIdentifier("selectUUID", sender: self)
            return false
        }
        return true;
    }
    

    func textFieldDidBeginEditing(textfield: UITextField){
        self.navigationItem.rightBarButtonItem = self.doneButton
    }
    
    func textFieldDidEndEditing(textfield: UITextField){
        switch (textfield){
        case self.majorTextField:
            major = numberFormatter!.numberFromString(textfield.text)
        case self.minorTextField:
            minor = numberFormatter!.numberFromString(textfield.text)
        case self.powerTextField:
            power = numberFormatter!.numberFromString(textfield.text)
            if(power!.intValue>0){
                power = NSNumber.numberWithInt(-power!.intValue)
            }
            textfield.text = power?.stringValue
        default:
            println("not expected text field")
        }

        navigationItem.rightBarButtonItem = nil;
        updateAdvertisedRegion()
        
    }

    func updateAdvertisedRegion() {
        
        var s = peripheralManager?.state
        if (s! != CBPeripheralManagerState.PoweredOn) {

            let alert = UIAlertView()
            alert.title = "Bluetooth must be enabled"
            alert.message = "To configure your device as a beacon"
            alert.addButtonWithTitle("OK")
            alert.show()
            
            return
        }
        
        peripheralManager!.stopAdvertising()
        
        if self.enabled {
            var peripheralData:NSDictionary?
            // init(proximityUUID: NSUUID!, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String!)
            var maj: UInt16 = UInt16(major.intValue)
            var min: UInt16 = UInt16(minor.intValue)
            region = CLBeaconRegion(proximityUUID: uuid, major: min, minor: min, identifier: Defaults.sharedDefaults().BeaconIdentifier)
            peripheralData = region!.peripheralDataWithMeasuredPower(power)
            // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
            if(peripheralData){
                println("start Advertising with uuid " + uuid.UUIDString)
                popupDebugAlert("start Advertising", message: "start Advertising with uuid " + uuid.UUIDString)
                peripheralManager!.startAdvertising(peripheralData)
            } else {
                println("Advertising not enabled")
                popupDebugAlert("Advertising not enabled", message: "" )
            }
        }


    }


    @IBAction func toggleEnabled(sender: UISwitch){
        enabled  = sender.on
        updateAdvertisedRegion()
    }
    
    @IBAction func doneEditing(sender: AnyObject){
        majorTextField.resignFirstResponder()
        minorTextField.resignFirstResponder()
        powerTextField.resignFirstResponder()
        
        tableView.reloadData()
    }

    override func  prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!){
        if segue?.identifier == "selectUUID" {
            var uuidSelector : UUIDViewController = segue.destinationViewController as UUIDViewController
            uuidSelector.uuid = self.uuid
        }
    }

    @IBAction func unwindUUIDSelector(sender: UIStoryboardSegue) {
        var uuidSelector : UUIDViewController = sender.sourceViewController as UUIDViewController
        self.uuid = uuidSelector.uuid!
        updateAdvertisedRegion()
    }
    
    func popupDebugAlert(title:NSString, message:NSString) {
        if(!_debugMode) {return}
        let alert = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButtonWithTitle("OK")
        alert.show()

    }

    
}

