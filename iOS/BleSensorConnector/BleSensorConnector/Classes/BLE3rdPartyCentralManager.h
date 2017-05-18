//
//  BLE3rdPartyCentralManager.h
//  Vodka
//
//  Created by Mark C.J. on 11/05/2017.
//  Copyright © 2017 Beijing Beast Technology Co.,Ltd. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "BLE3rdPartySensorPeripheral.h"
#import "BLE3rdPartySensorDefinitions.h"
#import "Definitions.h"

@interface BLE3rdPartyCentralManager : NSObject


instance_interface(BLE3rdPartyCentralManager, defaultManager)

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
