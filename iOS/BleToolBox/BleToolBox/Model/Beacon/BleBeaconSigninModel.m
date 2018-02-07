//
//  BleBeaconSignInModel.m
//  BleToolBox
//
//  Created by Mark on 2018/1/26.
//  Copyright © 2018年 MarkCJ. All rights reserved.
//

#import "BleBeaconSignInModel.h"

@implementation BleBeaconSignInModel

/**
 Init the beacon model by beacon information
 
 @param name            Device name
 @param deviceUUID      Device UUID
 @param serviceUUID     Device Service UUID
 @param rssi            RSSI value
 @param time            Sign in time
 @return
 */
-(instancetype)initWithBeaconName:(NSString *)name deviceUUID:(NSString *)deviceUUID serviceUUID:(NSString *)serviceUUID RSSI:(NSInteger)rssi signInTime:(NSDate *)time {
    self = [super init];
    
    self = [super initWithValue:@{
                          @"beaconName" : name,
                          @"beaconDeviceUUID" : deviceUUID,
                          @"beaconServiceUUID" : serviceUUID,
                          @"signInRSSI" : @(rssi),
                          @"signInTime" : time
                          }];
    
    return self;
}

@end
