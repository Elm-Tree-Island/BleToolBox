//
//  BLE3rdPartyCentralManager.h
//  Vodka
//
//  Created by Mark C.J. on 11/05/2017.
//  Copyright © 2017 Beijing Beast Technology Co.,Ltd. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "Definitions.h"

#import "BLEPowerSensorPeripheral.h"
#import "BLECSCSensorPeripheral.h"
#import "BLEHRSensorPeripheral.h"

@interface BLESensorCentralManager : NSObject

instance_interface(BLE3rdPartyCentralManager, defaultManager)

@property (nonatomic, weak) id<BLEPowerSensorPeripheralDelegate>    powerDelegate;
@property (nonatomic, weak) id<BLECSCSensorPeripheralDelegate>      cscDelegate;
@property (nonatomic, weak) id<BLEHRSensorPeripheralDelegate>       hrDelegate;

// 手机是否开启蓝牙，返回蓝牙使能状态
- (BOOL)isBLEEnabled;

/**
 *  Start Connect the SpeedX BLE Devices.
 */
- (void)scan;


/**
 断开连接

 @return BOOL
 */
- (BOOL) disconnect;

@end
