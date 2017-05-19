//
//  BLECRCSensorPeripheral.h
//  BleSensorConnector
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLECSCSensorPeripheralDelegate <NSObject>

- (void) didSpeedWheelRevolution:(int)wheelRevolution lastWheelEventTime:(int)lastEventTime;

- (void) didCadenceRevolution:(int)cadenceRev lastCadenceEventTime:(int)lastEventTime;

@end

@interface BLECSCSensorPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic, weak) id <BLECSCSensorPeripheralDelegate> delegate;

@property (nonatomic, strong) CBPeripheral *peripheral;              // PWR Peripheral
@property (nonatomic, strong) CBService *service;               // Cycling Speed and Cadence Service
@property (nonatomic, strong) CBCharacteristic *characteristic;      // CSC Measurement Characteristic


/**
 Initialize
 
 @param aPeripheral CBPeripheral Object
 @param aDelegate   Data receive delegate
 @return BLECSCSensorPeripheral Object
 */
- (BLECSCSensorPeripheral *) initWithPeripheral:(CBPeripheral *)aPeripheral delegate:(id<BLECSCSensorPeripheralDelegate>)aDelegate;

/**
 *  开始扫描设备上的Service信息
 */
- (void)scanServices;

/**
 *  清理资源
 */
- (void)cleanup;

@end
