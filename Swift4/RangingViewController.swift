//
//  RangingViewController.swift
//  Swift4
//
//  Created by John Walters on 7/4/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

import UIKit
import CoreLocation


class RangingViewController : UITableViewController, CLLocationManagerDelegate {
    
//    #import "APLDefaults.h"
//    @import CoreLocation;
//    
//    
//    @interface APLRangingViewController () <CLLocationManagerDelegate>
//    
//    @property NSMutableDictionary *beacons;
    var beacons: NSMutableDictionary
//    @property CLLocationManager *locationManager;
    var locationManager: CLLocationManager
//    @property NSMutableDictionary *rangedRegions;
    var rangedRegions: NSMutableDictionary
//    
//    @end
//    
//    
//    @implementation APLRangingViewController
//    
    init(coder: NSCoder!) {
        beacons = NSMutableDictionary()
        locationManager = CLLocationManager()
        rangedRegions = NSMutableDictionary()
        super.init(coder: coder)
        
    }

    override func viewDidLoad(){
        
        super.viewDidLoad()
        locationManager.delegate = self
    
        var d = Defaults.sharedDefaults().supportedProximityUUIDs
        for uuid: AnyObject in Defaults.sharedDefaults().supportedProximityUUIDs{
            var region = CLBeaconRegion(proximityUUID: uuid as NSUUID, identifier: uuid.UUIDString)
            rangedRegions[region] = NSArray.array()
        }
      }
//
//    - (void)viewDidAppear:(BOOL)animated
//    {
//    [super viewDidAppear:animated];
//    
//    // Start ranging when the view appears.
//    for (CLBeaconRegion *region in self.rangedRegions)
//    {
//    [self.locationManager startRangingBeaconsInRegion:region];
//    }
//    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Start ranging when the view appears.
        for region in rangedRegions {
            locationManager.startRangingBeaconsInRegion(region.key as CLBeaconRegion)
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Stop ranging when the view goes away.
        for region in rangedRegions {
            locationManager.stopRangingBeaconsInRegion(region.key as CLBeaconRegion)
        }
        
    }
    

//    
//    
//    #pragma mark - Location manager delegate
//    
//    - (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
//    {
//    /*
//    CoreLocation will call this delegate method at 1 Hz with updated range information.
//    Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
//    regions.  It will be displayed multiple times if that is the case.  If that is not desired,
//    use a set instead of an array.
//    */
//    self.rangedRegions[region] = beacons;
//    [self.beacons removeAllObjects];
//    
//    NSMutableArray *allBeacons = [NSMutableArray array];
//    
//    for (NSArray *regionResult in [self.rangedRegions allValues])
//    {
//    [allBeacons addObjectsFromArray:regionResult];
//    }
//    
//    for (NSNumber *range in @[@(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
//    {
//    NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
//    if([proximityBeacons count])
//    {
//    self.beacons[range] = proximityBeacons;
//    }
//    }
//    
//    [self.tableView reloadData];
//    }
//    
//    
//    #pragma mark - Table view data source
//    
//    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//    {
//    return self.beacons.count;
//    }
//    
//    
//    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//    {
//    NSArray *sectionValues = [self.beacons allValues];
//    return [sectionValues[section] count];
//    }
//    
//    
//    - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//    {
//    NSString *title;
//    NSArray *sectionKeys = [self.beacons allKeys];
//    
//    // The table view will display beacons by proximity.
//    NSNumber *sectionKey = sectionKeys[section];
//    
//    switch([sectionKey integerValue])
//    {
//    case CLProximityImmediate:
//    title = NSLocalizedString(@"Immediate", @"Immediate section header title");
//    break;
//    
//    case CLProximityNear:
//    title = NSLocalizedString(@"Near", @"Near section header title");
//    break;
//    
//    case CLProximityFar:
//    title = NSLocalizedString(@"Far", @"Far section header title");
//    break;
//    
//    default:
//    title = NSLocalizedString(@"Unknown", @"Unknown section header title");
//    break;
//    }
//    
//    return title;
//    }
//    
//    
//    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//    {
//    static NSString *identifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    
//    // Display the UUID, major, minor and accuracy for each beacon.
//    NSNumber *sectionKey = [self.beacons allKeys][indexPath.section];
//    CLBeacon *beacon = self.beacons[sectionKey][indexPath.row];
//    cell.textLabel.text = [beacon.proximityUUID UUIDString];
//    
//    NSString *formatString = NSLocalizedString(@"Major: %@, Minor: %@, Acc: %.2fm", @"Format string for ranging table cells.");
//    cell.detailTextLabel.text = [NSString stringWithFormat:formatString, beacon.major, beacon.minor, beacon.accuracy];
//    
//    return cell;
//    }
//
//    
}
