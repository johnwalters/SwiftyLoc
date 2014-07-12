//
//  CalibrationCalculator.swift
//  Swift4
//
//  Created by John Walters on 7/6/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//



import CoreLocation

class CalibrationCalculator : NSObject,CLLocationManagerDelegate {
    let CalibrationDwell:NSTimeInterval = 20.0
    var locationManager:CLLocationManager
    var region:CLBeaconRegion
    var isCalibrating = false
    var rangedBeacons:NSMutableArray = []
    var timer:NSTimer
    var percentComplete:Float? = 0.0
    var AppErrorDomain = "com.example.apple-samplecode.AirLocate"
    var progressHandler:(Float)->Void = { progress in }
    var completionHandler:(NSInteger,NSError)->Void = { measuredPower,error in }
    let increment1:Float = 1.0
    init(){
        locationManager = CLLocationManager()
        region = CLBeaconRegion()
        timer = NSTimer()

    }
    
    convenience init(region: CLBeaconRegion, progressHandler:((Float)->Void)){
        self.init()
        locationManager.delegate = self
        self.region = region
        self.progressHandler = progressHandler
        rangedBeacons = NSMutableArray()
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!){

//        swift's equivalant to @synchronized(self) {}
//        objc_sync_enter(self)
//            ... synchronized code ...
//                objc_sync_exit(self)
        
//        http://stackoverflow.com/questions/24045895/what-is-the-swift-equivalent-to-objective-cs-synchronized
        objc_sync_enter(self)
        rangedBeacons.addObject(beacons)
//        if progressHandler {
            dispatch_async(dispatch_get_main_queue(),
                {
                    var bump:Float = (self.increment1 + 1)
                    bump = bump / Float(self.CalibrationDwell)
                    self.percentComplete = bump
                    self.progressHandler(self.percentComplete!)
                }
        )
        objc_sync_exit(self)
    }
    
    
    
    func performCalibrationWithProgressHandler(progressHandler:((Float)->Void)) {
        objc_sync_enter(self)
            if !isCalibrating {
                isCalibrating = true;
                rangedBeacons.removeAllObjects()
                percentComplete = 0.0
                self.progressHandler = progressHandler
                locationManager.startRangingBeaconsInRegion(region)
                var interval0:Double = Double(0)
                var calibrationDwellDate = NSDate(timeIntervalSinceNow: 0)
                timer = NSTimer(fireDate: calibrationDwellDate, interval: 0, target: self, selector: "timerElapsed:", userInfo: nil, repeats: false)
                NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
            } else {
                // Send back an error if calibration is already in progress.
                var localizedErrorString = NSLocalizedString("Calibration is already in progress", comment: "Error string");
                var userInfo:NSDictionary = NSDictionary(object: localizedErrorString,forKey: NSLocalizedDescriptionKey)
                var error:NSError = NSError(domain: AppErrorDomain, code: 4, userInfo: userInfo)
                dispatch_async(dispatch_get_main_queue()) {self.completionHandler(0, error)} ;

            }
        objc_sync_exit(self)
    }
    
    
func cancelCalibration(){
    objc_sync_enter(self)
        if isCalibrating {
            isCalibrating=false
            timer.fire()
            
        }
        dispatch_get_main_queue()
    objc_sync_exit(self)
    }
    
    
    func timerElapsed(sender:AnyObject){
        
        //{
        //    @synchronized(self)
        //    {
                // We can stop ranging at this point as we've either been cancelled or
                // collected all of the RSSI samples we need.
        locationManager.stopRangingBeaconsInRegion(region)
        var blockOfCode:()->Void = {
            objc_sync_enter(self)
            var error:NSError?
            var allBeacons = NSMutableArray()
            var measuredPower = NSInteger(0)
            if(self.isCalibrating) {
                var localizedErrorString = NSLocalizedString("Calibration was cancelled", comment: "Error string");
                var userInfo:NSDictionary = NSDictionary(object: localizedErrorString,forKey: NSLocalizedDescriptionKey)
                var error:NSError = NSError(domain: self.AppErrorDomain, code: 2, userInfo: userInfo)
            } else {
                
                self.rangedBeacons.enumerateObjectsUsingBlock({obj, idx, stop in
                    //                        NSArray *beacons = (NSArray *)obj;
                    var beacons:NSArray = obj as NSArray
                    if beacons.count > 1 {
                        var localizedErrorString = NSLocalizedString("More than one beacon of the specified type was found", comment: "Error string");
                        var userInfo:NSDictionary = NSDictionary(object: localizedErrorString,forKey: NSLocalizedDescriptionKey)
                        var error:NSError = NSError(domain: self.AppErrorDomain, code: 1, userInfo: userInfo)
//                        stop = true
                    } else {
                        allBeacons.addObjectsFromArray(beacons)
                    }
                    
                    }
                    )
                if allBeacons.count <= 0 {
                    var localizedErrorString = NSLocalizedString("No beacon of the specified type was found", comment: "Error string");
                    var userInfo:NSDictionary = NSDictionary(object: localizedErrorString,forKey: NSLocalizedDescriptionKey)
                    var error:NSError = NSError(domain: self.AppErrorDomain, code: 3, userInfo: userInfo)
                } else {
                    //                        // Measured power is an average of the mid-80th percentile of RSSI samples.
                    var outlierPadding:UInt = UInt(Float(allBeacons.count) * 0.1)
                    var sortDescriptor:NSSortDescriptor = NSSortDescriptor(key: "rssi", ascending: true)
                    allBeacons.sortUsingDescriptors([sortDescriptor])
   
                    var sample:NSArray = allBeacons.subarrayWithRange(NSMakeRange(Int(outlierPadding), allBeacons.count - (Int(outlierPadding) * 2)))
                    measuredPower = sample.valueForKeyPath("avg.rssi").integerValue
                    
                }
              
            }
            dispatch_async(dispatch_get_main_queue()) {self.completionHandler(measuredPower, error!)} ;
            self.isCalibrating = false
            self.rangedBeacons.removeAllObjects()
//            progressHandler = nil
            objc_sync_exit(self)
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), blockOfCode)
               

        
    }
    
    
}






//    - (void)timerElapsed:(id)sender

//{
//    @synchronized(self)
//    {
//        // We can stop ranging at this point as we've either been cancelled or
//        // collected all of the RSSI samples we need.
//        [_locationManager stopRangingBeaconsInRegion:_region];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            @synchronized(self) {
//                __block NSError *error = nil;
//                NSMutableArray *allBeacons = [[NSMutableArray alloc] init];
//                NSInteger measuredPower = 0;
//                if(!self.calibrating)
//                {
//                    NSString *localizedErrorString = NSLocalizedString(@"Calibration was cancelled", @"Error string");
//                    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : localizedErrorString };
//                    error = [NSError errorWithDomain:AppErrorDomain code:2 userInfo:userInfo];
//                }
//                else
//                {
//                    [self.rangedBeacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                        NSArray *beacons = (NSArray *)obj;
//                        if(beacons.count > 1)
//                        {
//                        NSString *localizedErrorString = NSLocalizedString(@"More than one beacon of the specified type was found", @"Error string");
//                        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : localizedErrorString };
//                        error = [NSError errorWithDomain:AppErrorDomain code:1 userInfo:userInfo];
//                        *stop = YES;
//                        }
//                        else
//                        {
//                        [allBeacons addObjectsFromArray:beacons];
//                        }
//                        }];
//                    
//                    if(allBeacons.count <= 0)
//                    {
//                        NSString *localizedErrorString = NSLocalizedString(@"No beacon of the specified type was found", @"Error string");
//                        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : localizedErrorString };
//                        error = [NSError errorWithDomain:AppErrorDomain code:3 userInfo:userInfo];
//                    }
//                    else
//                    {
//                        // Measured power is an average of the mid-80th percentile of RSSI samples.
//                        NSUInteger outlierPadding = allBeacons.count * 0.1f;
//                        [allBeacons sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rssi" ascending:YES]]];
//                        NSArray *sample = [allBeacons subarrayWithRange:NSMakeRange(outlierPadding, allBeacons.count - (outlierPadding * 2))];
//                        measuredPower = [[sample valueForKeyPath:@"@avg.rssi"] integerValue];
//                    }
//                }
//                
//                // Bump the completion callback to the UI thread as we'll be updating the UI.
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    _completionHandler(measuredPower, error);
//                    });
//                
//                self.calibrating = NO;
//                [self.rangedBeacons removeAllObjects];
//                
//                self.progressHandler = nil;
//            }
//            });
//    }
//}
