//
//  AppDelegate.swift
//  Swift4
//
//  Created by John Walters on 6/22/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
                            
    var window: UIWindow?
    var _locationManager: CLLocationManager?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        _locationManager = CLLocationManager()
        _locationManager!.delegate = self
        return true
    }
    
     func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        var notification = UILocalNotification()
        if state == CLRegionState.Inside {
            notification.alertBody = NSLocalizedString("You're inside the region", comment:"");
        } else if state == CLRegionState.Outside {
            notification.alertBody = NSLocalizedString("You're outside the region", comment:"");

        } else {
            return
        }
        
        /*
        If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
        If it's not, iOS will display the notification to the user.
        */
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func application(application: UIApplication!, didReceiveLocalNotification notification: UILocalNotification!) {
        // If the application is in the foreground, we will notify the user of the region's state via an alert.
        var cancelButtonTitle:NSString = NSLocalizedString("OK",  comment: "Title for cancel button in local notification")
        var alert = UIAlertView(title: notification.alertBody, message: "", delegate: nil, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: "" )
        alert.show()
    }
    
   

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

