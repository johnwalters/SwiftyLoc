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

    var locationManager:CLLocationManager
    var beacons:NSMutableDictionary
    var rangedRegions:NSMutableArray
    var calculator:CalibrationCalculator
    var inProgress = false
    
    init(coder: NSCoder!) {
        beacons = NSMutableDictionary()
        locationManager = CLLocationManager()
        rangedRegions = NSMutableArray()
        calculator = CalibrationCalculator()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        inProgress = false
        
        // Populate the regions for the beacons we're interested in calibrating.
        for uuid: AnyObject in Defaults.sharedDefaults().supportedProximityUUIDs{
            var region = CLBeaconRegion(proximityUUID: uuid as NSUUID, identifier: uuid.UUIDString)
            rangedRegions.addObject(region)
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
        calculator.cancelCalibration()
        self.stopRangingAllRegions()
    }
    
    func startRangingAllRegions(){
        for region in rangedRegions{
            locationManager.startRangingBeaconsInRegion(region as CLBeaconRegion)
        }
    }
    
    func stopRangingAllRegions(){
        for region in rangedRegions{
            locationManager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beaconsObj: [AnyObject]!, inRegion region: CLBeaconRegion!)
    {
            // CoreLocation will call this delegate method at 1 Hz with updated range information.
            // Beacons will be categorized and displayed by proximity.
        self.beacons.removeAllObjects()
        var beacons = NSArray(array: beaconsObj)
        var unknownBeacons: NSArray = beacons.filteredArrayUsingPredicate(NSPredicate(format: "proximity = %d",  CLProximity.Unknown.toRaw()))
        if unknownBeacons.count > 0 {
            self.beacons[CLProximity.Unknown.toRaw()] = unknownBeacons
        }
        
        var immediateBeacons: NSArray = beacons.filteredArrayUsingPredicate(NSPredicate(format: "proximity = %d",  CLProximity.Immediate.toRaw()))
        if immediateBeacons.count > 0 {
            self.beacons[CLProximity.Immediate.toRaw()] = immediateBeacons
        }
        
        var nearBeacons: NSArray = beacons.filteredArrayUsingPredicate(NSPredicate(format: "proximity = %d",  CLProximity.Near.toRaw()))
        if nearBeacons.count > 0 {
            self.beacons[CLProximity.Near.toRaw()] = nearBeacons
        }
        
        var farBeacons: NSArray = beacons.filteredArrayUsingPredicate(NSPredicate(format: "proximity = %d",  CLProximity.Far.toRaw()))
        if farBeacons.count > 0 {
            self.beacons[CLProximity.Far.toRaw()] = farBeacons
        }
        
        self.tableView.reloadData()
    }
    
    func updateProgressViewWithProgress(percentComplete:Float) {
        if(!inProgress){
            return
        }
        var indexPath = NSIndexPath(forRow: 0, inSection: 0)
        var progressCell = self.tableView.cellForRowAtIndexPath(indexPath) as ProgressTableViewCell
        progressCell.progressView?.setProgress(percentComplete, animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var i  = inProgress ? beacons.count + 1 : beacons.count
        return i
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var adjustedSection = section
        if inProgress {
            if adjustedSection == 0 {
                return 1
            } else {
                adjustedSection--
            }
            
        }
        
        var sectionValues = beacons.allValues
        return sectionValues[adjustedSection].count
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        return cell
//    }
    
//    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//    {
//    static NSString *beaconCellIdentifier = @"BeaconCell";
//    static NSString *progressCellIdentifier = @"ProgressCell";
//    
//    NSInteger section = indexPath.section;
//    NSString *identifier = self.inProgress && section == 0 ? progressCellIdentifier : beaconCellIdentifier;
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    
//    if(identifier == progressCellIdentifier)
//    {
//    return cell;
//    }
//    else if(self.inProgress)
//    {
//    section--;
//    }
//    
//    NSNumber *sectionKey = [self.beacons allKeys][section];
//    CLBeacon *beacon = self.beacons[sectionKey][indexPath.row];
//    cell.textLabel.text = [beacon.proximityUUID UUIDString];
//    NSString *formatString = NSLocalizedString(@"Major: %@, Minor: %@, Acc: %.2fm", @"format string for detail");
//    cell.detailTextLabel.text = [NSString stringWithFormat:formatString, beacon.major, beacon.minor, beacon.accuracy];
//    
//    return cell;
//    }

    


}
