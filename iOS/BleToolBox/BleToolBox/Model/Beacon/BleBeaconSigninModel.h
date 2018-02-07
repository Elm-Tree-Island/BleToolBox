//
//  BleBeaconSignInModel.h
//  BleToolBox
//
//  Created by Mark on 2018/1/26.
//  Copyright © 2018年 MarkCJ. All rights reserved.
//

#import "BleBaseModel.h"

@interface BleBeaconSignInModel : BleBaseModel

@property NSString *beaconName;             // the beacon name.
@property NSString *beaconDeviceUUID;       // the beacon UUID.
@property NSString *beaconServiceUUID;      // the beacon service UUID.
@property NSInteger signInRSSI;             // the beacon RSSI when sign in.
@property NSDate *signInTime;               // time then sign in.

/**
 Init the beacon model by beacon information
 
 @param name            Device name
 @param deviceUUID      Device UUID
 @param serviceUUID     Device Service UUID
 @param rssi            RSSI value
 @param time            Sign in time
 */
-(instancetype)initWithBeaconName:(NSString *)name deviceUUID:(NSString *)deviceUUID serviceUUID:(NSString *)serviceUUID RSSI:(NSInteger)rssi signInTime:(NSDate *)time;

@end
