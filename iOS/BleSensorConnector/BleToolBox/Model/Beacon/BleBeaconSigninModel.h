//
//  BleBeaconSignInModel.h
//  BleToolBox
//
//  Created by Mark on 2018/1/26.
//  Copyright © 2018年 MarkCJ. All rights reserved.
//

#import "BleBaseModel.h"

@interface BleBeaconSignInModel : BleBaseModel

@property NSString *beaconName;     // the beacon name.
@property NSString *beaconUUID;     // the beacon UUID.
@property NSInteger signInRSSI;     // the beacon RSSI when sign in.
@property NSDate *signInTime;       // time then sign in.

/**
 <#Description#>

 @param name <#name description#>
 @param uuid <#uuid description#>
 @param rssi <#rssi description#>
 @param time <#time description#>
 @return <#return value description#>
 */
-(instancetype)initWithBeaconName:(NSString *)name UUID:(NSString *)uuid RSSI:(NSInteger)rssi signInTime:(NSDate *)time;

@end
