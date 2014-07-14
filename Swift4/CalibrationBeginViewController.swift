//
//  CalibrationBeginViewController.swift
//  Swift4
//
//  Created by John Walters on 7/12/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

import UIKit
import CoreLocation;


class CalibrationBeginViewController: UITableViewController, CLLocationManagerDelegate {

    let BeaconIdentifier = "com.example.apple-samplecode.AirLocate"
    var _locationManager:CLLocationManager
    var _beacons:NSMutableDictionary
    var _rangedRegions:NSMutableArray
    var _calculator:CalibrationCalculator?
    var _isInProgress = false
    
    init(coder: NSCoder!) {
        _beacons = NSMutableDictionary()
        _locationManager = CLLocationManager()
        _rangedRegions = NSMutableArray()
        _calculator = CalibrationCalculator()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _locationManager.delegate = self
        _isInProgress = false
        
        // Populate the regions for the beacons we're interested in calibrating.
        for uuid: AnyObject in Defaults.sharedDefaults().supportedProximityUUIDs{
            var region = CLBeaconRegion(proximityUUID: uuid as NSUUID, identifier: uuid.UUIDString)
            _rangedRegions.addObject(region)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start ranging to show the beacons available for calibration.
        self.startRangingAllRegions()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Cancel calibration (if it was started) and stop ranging when the view goes away.
        _calculator!.cancelCalibration()
        self.stopRangingAllRegions()
    }
    
    func startRangingAllRegions(){
        for region in _rangedRegions{
            _locationManager.startRangingBeaconsInRegion(region as CLBeaconRegion)
        }
    }
    
    func stopRangingAllRegions(){
        for region in _rangedRegions{
            _locationManager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beaconsObj: [AnyObject]!, inRegion region: CLBeaconRegion!)
    {
            // CoreLocation will call this delegate method at 1 Hz with updated range information.
            // Beacons will be categorized and displayed by proximity.
        _beacons.removeAllObjects()
        var beacons = NSArray(array: beaconsObj)
        var unknownBeacons: NSArray = beacons.filteredArrayUsingPredicate(NSPredicate(format: "proximity = %d",  CLProximity.Unknown.toRaw()))
        if unknownBeacons.count > 0 {
            _beacons[CLProximity.Unknown.toRaw()] = unknownBeacons
        }
        
        var immediateBeacons: NSArray = beacons.filteredArrayUsingPredicate(NSPredicate(format: "proximity = %d",  CLProximity.Immediate.toRaw()))
        if immediateBeacons.count > 0 {
            _beacons[CLProximity.Immediate.toRaw()] = immediateBeacons
        }
        
        var nearBeacons: NSArray = beacons.filteredArrayUsingPredicate(NSPredicate(format: "proximity = %d",  CLProximity.Near.toRaw()))
        if nearBeacons.count > 0 {
            _beacons[CLProximity.Near.toRaw()] = nearBeacons
        }
        
        var farBeacons: NSArray = beacons.filteredArrayUsingPredicate(NSPredicate(format: "proximity = %d",  CLProximity.Far.toRaw()))
        if farBeacons.count > 0 {
            _beacons[CLProximity.Far.toRaw()] = farBeacons
        }
        
        self.tableView.reloadData()
    }
    
    func updateProgressViewWithProgress(percentComplete:Float) {
        if(!_isInProgress){
            return
        }
        var indexPath = NSIndexPath(forRow: 0, inSection: 0)
        var progressCell = self.tableView.cellForRowAtIndexPath(indexPath) as ProgressTableViewCell
        progressCell.progressView?.setProgress(percentComplete, animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var i  = _isInProgress ? _beacons.count + 1 : _beacons.count
        return i
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var adjustedSection = section
        if _isInProgress {
            if adjustedSection == 0 {
                return 1
            } else {
                adjustedSection--
            }
            
        }
        
        var sectionValues = _beacons.allValues
        return sectionValues[adjustedSection].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var beaconCellIdentifier = "BeaconCell"
        var progressCellIdentifier = "ProgressCell"
        var section = indexPath.section
        var identifier = _isInProgress && section == 0 ? progressCellIdentifier : beaconCellIdentifier
        var cell: AnyObject! = tableView.dequeueReusableCellWithIdentifier(identifier)
        if identifier == progressCellIdentifier {
            return cell as ProgressTableViewCell
        } else if _isInProgress {
            section--
        }
        var sectionKey: NSNumber = _beacons.allKeys[section] as NSNumber
        var sectionBeacons = _beacons[sectionKey] as NSArray
        var beacon = sectionBeacons[indexPath.row] as CLBeacon
        cell.textLabel!.text = beacon.proximityUUID.UUIDString
         var localizedErrorString = NSLocalizedString("Major: %@, Minor: %@, Acc: %.2fm", comment: "format string for detail");
        cell.detailTextLabel!.text  = NSString(format: localizedErrorString, beacon.major, beacon.minor, beacon.accuracy)
        
        return cell as UITableViewCell
    }
    
    
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if _isInProgress && indexPath.section == 0 {
            return 66.0
        } else {
            return 44.0
        }
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var sectionKey = _beacons.allKeys[indexPath.section] as NSArray
        var sectionKeyBeacon = _beacons[sectionKey] as NSArray
        var beacon = sectionKeyBeacon[indexPath.row] as CLBeacon
        
        if !_isInProgress {
            var region:CLBeaconRegion? = nil
            if (beacon.proximityUUID && beacon.major && beacon.minor) {
                var beaconMajor: UInt16 = UInt16(beacon.major.shortValue)
                var beaconMinor: UInt16 = UInt16(beacon.minor.shortValue)
                region = CLBeaconRegion(proximityUUID: beacon.proximityUUID, major: beaconMajor, minor: beaconMinor, identifier: BeaconIdentifier)
            } else if (beacon.proximityUUID && beacon.major) {
                var beaconMajor: UInt16 = UInt16(beacon.major.shortValue)
                region = CLBeaconRegion(proximityUUID: beacon.proximityUUID, major: beaconMajor, identifier: BeaconIdentifier)
            } else if (beacon.proximityUUID) {
                region = CLBeaconRegion(proximityUUID: beacon.proximityUUID, identifier: BeaconIdentifier)
            }
            
            if region {
                // We can stop ranging to display beacons available for calibration.
                stopRangingAllRegions()
                
                // And we'll start the calibration process.
                var stubCompletionHandler:(NSInteger,NSError?)->Void = { measuredPower,error in
                
                    if error {
                        // Only display if the view is showing.
                        if self.view.window {
                            var title = NSLocalizedString("Unable to calibrate device",comment:"Alert title for calibration begin view controller")
                            var cancelTitle = NSLocalizedString("OK",comment: "Alert OK title for calibration begin view controller")
                            var localUserError: NSString = error!.userInfo[NSLocalizedDescriptionKey] as NSString
                            var alert = UIAlertView(title: title, message: localUserError, delegate: nil, cancelButtonTitle: cancelTitle)
                            alert.show()
                            
                            // Resume displaying beacons available for calibration if the calibration process failed.
                            self.startRangingAllRegions()
                        } else {
                            var endViewController = self.storyboard.instantiateViewControllerWithIdentifier("EndViewController") as CalibrationEndViewController
                            endViewController.measuredPower = measuredPower
                            self.navigationController.pushViewController(endViewController, animated: true)
                        }
                        self._isInProgress = true
                        self._calculator = nil
                        self.tableView.reloadData()
                    }
                    
                    
                    }
                
                 _calculator = CalibrationCalculator(region: region!, stubCompletionHandler)
                    
                
                }
            
                
            }
        }
    }

   //
//    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//    {
//    NSNumber *sectionKey = [self.beacons allKeys][indexPath.section];
//    CLBeacon *beacon = self.beacons[sectionKey][indexPath.row];
//    
//    if(!self.inProgress)
//    {
//    CLBeaconRegion *region = nil;
//    if(beacon.proximityUUID && beacon.major && beacon.minor)
//    {
//    region = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID major:[beacon.major shortValue] minor:[beacon.minor shortValue] identifier:BeaconIdentifier];
//    }
//    else if(beacon.proximityUUID && beacon.major)
//    {
//    region = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID major:[beacon.major shortValue] identifier:BeaconIdentifier];
//    }
//    else if(beacon.proximityUUID)
//    {
//    region = [[CLBeaconRegion alloc] initWithProximityUUID:beacon.proximityUUID identifier:BeaconIdentifier];
//    }
//    
//    if(region)
//    {
//    // We can stop ranging to display beacons available for calibration.
//    [self stopRangingAllRegions];
//    
//    // And we'll start the calibration process.
//    self.calculator = [[APLCalibrationCalculator alloc] initWithRegion:region completionHandler:^(NSInteger measuredPower, NSError *error) {
//    if(error)
//    {
//    // Only display if the view is showing.
//    if(self.view.window)
//    {
//    NSString *title = NSLocalizedString(@"Unable to calibrate device", @"Alert title for calibration begin view controller");
//    NSString *cancelTitle = NSLocalizedString(@"OK", @"Alert OK title for calibration begin view controller");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:(error.userInfo)[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil];
//    [alert show];
//    
//    // Resume displaying beacons available for calibration if the calibration process failed.
//    [self startRangingAllRegions];
//    }
//    }
//    else
//    {
//    APLCalibrationEndViewController *endViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EndViewController"];
//    endViewController.measuredPower = measuredPower;
//    [self.navigationController pushViewController:endViewController animated:YES];
//    }
//    
//    self.inProgress = NO;
//    self.calculator = nil;
//    
//    [self.tableView reloadData];
//    }];
//    
//    __weak APLCalibrationBeginViewController *weakSelf = self;
//    [self.calculator performCalibrationWithProgressHandler:^(float percentComplete) {
//    [weakSelf updateProgressViewWithProgress:percentComplete];
//    }];
//    
//    self.inProgress = YES;
//    [self.tableView beginUpdates];
//    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
//    [self updateProgressViewWithProgress:0.0];
//    }
//    }
//    }


