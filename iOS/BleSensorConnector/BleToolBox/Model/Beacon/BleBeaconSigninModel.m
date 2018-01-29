//
//  BleBeaconSignInModel.m
//  BleToolBox
//
//  Created by Mark on 2018/1/26.
//  Copyright © 2018年 MarkCJ. All rights reserved.
//

#import "BleBeaconSignInModel.h"

@implementation BleBeaconSignInModel

-(instancetype)initWithBeaconName:(NSString *)name UUID:(NSString *)uuid RSSI:(NSInteger)rssi signInTime:(NSDate *)time {
    self = [super init];
    
    self = [super initWithValue:@{
                          @"beaconName" : name,
                          @"beaconUUID" : uuid,
                          @"signInRSSI" : @(rssi),
                          @"signInTime" : time
                          }];
    
    return self;
}

@end
