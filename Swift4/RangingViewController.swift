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
    

    var beacons: NSMutableDictionary

    var locationManager: CLLocationManager

    var rangedRegions: NSMutableDictionary
 
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
    


    
    func locationManager(manager: CLLocationManager!, beacons: NSArray, region: CLBeaconRegion!){
            /*
            CoreLocation will call this delegate method at 1 Hz with updated range information.
            Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
            regions.  It will be displayed multiple times if that is the case.  If that is not desired,
            use a set instead of an array.
            */
        self.rangedRegions[region] = beacons
        self.beacons.removeAllObjects()
        var allBeacons = NSMutableArray()
        for regionResult : AnyObject in self.rangedRegions.allValues{
            var regionResultArry = regionResult as NSArray
            allBeacons.addObjectsFromArray(regionResult as NSArray)
        }
        let ranges = [CLProximity.Unknown,CLProximity.Immediate,CLProximity.Near,CLProximity.Far]
        for range in ranges {
            var proximityBeacons: NSArray = allBeacons.filteredArrayUsingPredicate(NSPredicate(format: "proximity = %d",  [range.toRaw()]))
        }
        self.tableView.reloadData()
        }


    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.beacons.count
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        var sectionValues = self.beacons.allValues
        return sectionValues[section].count
    }

    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        var title:String
        var sectionKeys = beacons.allKeys
        var sectionKey = sectionKeys[section] as NSNumber
        switch sectionKey{
        case CLProximity.Immediate.toRaw():
            title = NSLocalizedString("Immediate", comment: "Immediate section header title")
        case CLProximity.Near.toRaw():
            title = NSLocalizedString("Near", comment: "Near section header title")
        case CLProximity.Far.toRaw():
            title = NSLocalizedString("Far", comment: "Far section header title")
        default:
            title = NSLocalizedString("Unknown", comment: "Unknown section header title")

        }
        return title
    }
  

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var identifier = "Cell"
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell

        // Display the UUID, major, minor and accuracy for each beacon.
        let sectionKey : NSNumber = self.beacons.allKeys[indexPath.section] as NSNumber
        let keyedItem : NSArray  = self.beacons[indexPath.section] as NSArray
        let indexPathRow = indexPath.row

        
        let beacon:CLBeacon = keyedItem[indexPathRow] as CLBeacon
        cell.textLabel.text = beacon.proximityUUID.UUIDString
        var formatString = NSLocalizedString("Major: %@, Minor: %@, Acc: %.2fm", comment: "Format string for ranging table cells.")
        cell.detailTextLabel.text = NSString(format: formatString,beacon.major,beacon.minor,beacon.accuracy)

        return cell

    }

}
