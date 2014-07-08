//
//  CalibrationCalculator.swift
//  Swift4
//
//  Created by John Walters on 7/6/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

//
//
//@import CoreLocation;
//
//typedef void (^APLCalibrationProgressHandler)(float percentComplete);
//typedef void (^APLCalibrationCompletionHandler)(NSInteger measuredPower, NSError *error);
//
//static const NSTimeInterval ALCalibrationDwell = 20.0f;
//
//NSString *AppErrorDomain = @"com.example.apple-samplecode.AirLocate";
//
//
//
//@interface APLCalibrationCalculator()
//
//@property CLLocationManager *locationManager;
//@property CLBeaconRegion *region;
//@property (getter=isCalibrating) BOOL calibrating;
//@property NSMutableArray *rangedBeacons;
//@property NSTimer *timer;
//
//@property (strong) APLCalibrationProgressHandler progressHandler;
//@property (strong) APLCalibrationCompletionHandler completionHandler;
//
//@property float percentComplete;
//
//@end
//
//

import CoreLocation

class CalibrationCalculator : NSObject,CLLocationManagerDelegate {
    let CalibrationDwell:Float = 20.0
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
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: AnyObject[]!, inRegion region: CLBeaconRegion!){
        //    // CoreLocation will call this delegate method at 1 Hz with updated range information.
        //    @synchronized(self)
        //    {
        rangedBeacons.addObject(beacons)
//        if progressHandler {
            dispatch_async(dispatch_get_main_queue(),
                {
                    var bump:Float = (self.increment1 + 1)
                    bump = bump / self.CalibrationDwell
                    self.percentComplete = bump
                    self.progressHandler(self.percentComplete!)
                }
        )
//        }
        //        [_rangedBeacons addObject:beacons];
        //
        //        if(_progressHandler)
        //        {
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                // Bump the progress callback back to the UI thread as we'll be updating the UI.
        //                _percentComplete += 1.0f / ALCalibrationDwell;
        //                _progressHandler(_percentComplete);
        //                });
        //        }
        //    }
        //    }
    }
    
    func timerElapsed(sender:AnyObject){
        // Bump the completion callback to the UI thread as we'll be updating the UI.
        var measuredPower:NSInteger = 0;
        //            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : localizedErrorString };
        var userInfo:NSDictionary = NSDictionary()
// NSError *error = [NSError errorWithDomain:AppErrorDomain code:4 userInfo:userInfo];
        var error:NSError = NSError(domain: AppErrorDomain, code: 4, userInfo: userInfo)
            dispatch_async(dispatch_get_main_queue()) {self.completionHandler(measuredPower, error)} ;
        
    }
}


//    
//    - (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region

//{
//    // CoreLocation will call this delegate method at 1 Hz with updated range information.
//    @synchronized(self)
//    {
//        [_rangedBeacons addObject:beacons];
//        
//        if(_progressHandler)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // Bump the progress callback back to the UI thread as we'll be updating the UI.
//                _percentComplete += 1.0f / ALCalibrationDwell;
//                _progressHandler(_percentComplete);
//                });
//        }
//    }
//    }
//    
//    - (void)performCalibrationWithProgressHandler:(APLCalibrationProgressHandler)handler
//{
//    @synchronized(self)
//    {
//        if(!self.calibrating)
//        {
//            // Calibration consists of collecting RSSI samples for 20 seconds.
//            // Once we have all the samples we will average the mid-80th percentile in timerElapsed:.
//            self.calibrating = YES;
//            [self.rangedBeacons removeAllObjects];
//            
//            self.percentComplete = 0.0f;
//            self.progressHandler = [handler copy];
//            
//            [self.locationManager startRangingBeaconsInRegion:self.region];
//            
//            self.timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ALCalibrationDwell] interval:0 target:self selector:@selector(timerElapsed:) userInfo:nil repeats:NO];
//            [[NSRunLoop currentRunLoop] addTimer:self.timer  forMode:NSDefaultRunLoopMode];
//        }
//        else
//        {
//            // Send back an error if calibration is already in progress.
//            NSString *localizedErrorString = NSLocalizedString(@"Calibration is already in progress", @"Error string");
//            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : localizedErrorString };
//            NSError *error = [NSError errorWithDomain:AppErrorDomain code:4 userInfo:userInfo];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _completionHandler(0, error);
//                });
//        }
//    }
//    }
//    
//    - (void)cancelCalibration
//{
//    @synchronized(self)
//    {
//        // Fire the timer early if calibration is being cancelled.
//        // timerElapsed: will handle reporting the cancellation.
//        if(self.calibrating)
//        {
//            self.calibrating = NO;
//            [self.timer fire];
//        }dispatch_get_main_queue
//    }
//    }
//    
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
