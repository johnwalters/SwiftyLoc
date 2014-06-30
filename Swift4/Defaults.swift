//
//  Defaults.swift
//  Swift4
//
//  Created by John Walters on 6/24/14.
//  Copyright (c) 2014 Lapizon. All rights reserved.
//

// .h
//@import Foundation;
//
//
//extern NSString *BeaconIdentifier;
//
//
//@interface APLDefaults : NSObject
//
//+ (APLDefaults *)sharedDefaults;
//
//@property (nonatomic, copy, readonly) NSArray *supportedProximityUUIDs;
//
//@property (nonatomic, copy, readonly) NSUUID *defaultProximityUUID;
//@property (nonatomic, copy, readonly) NSNumber *defaultPower;
//
//@end

//.m

import Foundation
class Defaults{
var supportedProximityUUIDs:NSArray = []
var defaultPower = 0
let BeaconIdentifier = "com.example.apple-samplecode.AirLocate"
    

    init(){
        var uid1 = NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
        var uid2 = NSUUID(UUIDString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")
        var uid3 = NSUUID(UUIDString: "74278BDA-B644-4520-8F0C-720EAF059935")
        supportedProximityUUIDs = [uid1,uid2,uid3]
        defaultPower = -59
    }
//NSString *BeaconIdentifier = @"com.example.apple-samplecode.AirLocate";
//
//
//@implementation APLDefaults
//
//- (id)init
//{
//    self = [super init];
//    if(self)
//    {
//        // uuidgen should be used to generate UUIDs.
//        _supportedProximityUUIDs = @[[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"],
//        [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"],
//        [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"]];
//        _defaultPower = @-59;
//    }
//    
//    return self;
//}
//
//
//+ (APLDefaults *)sharedDefaults
//{
//    static id sharedDefaults = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//    sharedDefaults = [[self alloc] init];
//    });
//    
//    return sharedDefaults;
//    }
    
    class func  sharedDefaults() -> Defaults{
        var sharedDefaults = Defaults()
        return sharedDefaults
}
//
//    
//    - (NSUUID *)defaultProximityUUID
//{
//    return _supportedProximityUUIDs[0];
//}
    func defaultProximityUUID() -> NSUUID {
        return supportedProximityUUIDs.objectAtIndex(0) as NSUUID
    }
//
//
//@end
}
