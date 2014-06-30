//
//  UUIDViewController.swift
//  Swift4
//
//  Created by John Walters on 6/27/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

import UIKit

class UUIDViewController: UITableViewController {
    var uuid : NSUUID? = NSUUID()
    
    

    override func  numberOfSectionsInTableView(tableView: UITableView!) -> Int  {
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return Defaults.sharedDefaults().supportedProximityUUIDs.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var CellIdentifier = "Cell"
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as UITableViewCell
        if indexPath.row  < Defaults.sharedDefaults().supportedProximityUUIDs.count {
            cell.textLabel.text = Defaults.sharedDefaults().supportedProximityUUIDs[indexPath.row].UUIDString
            if uuid!.isEqual(Defaults.sharedDefaults().supportedProximityUUIDs[indexPath.row]){
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        var selectionIndexPath = tableView.indexPathForSelectedRow()
        var selection = 0;
        if selectionIndexPath.row < Defaults.sharedDefaults().supportedProximityUUIDs.count{
            selection = selectionIndexPath.row
        }
        uuid = Defaults.sharedDefaults().supportedProximityUUIDs[selection] as? NSUUID
    }


}
