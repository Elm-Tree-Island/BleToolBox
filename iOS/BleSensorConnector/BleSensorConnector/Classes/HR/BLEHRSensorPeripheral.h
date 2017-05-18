//
//  BLEHRSensorPeripheral.h
//  BleSensorConnector
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEHRSensorPeripheralDelegate <NSObject>

- (void) didHRDataReceived:(int) hr;

@end

@interface BLEHRSensorPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic, weak) id <BLEHRSensorPeripheralDelegate> delegate;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBService *service;
@property (nonatomic, strong) CBCharacteristic *characteristic;


/**
 Initialize
 
 @param aPeripheral CBPeripheral Object
 @param aDelegate   Data receive delegate
 @return BLECSCSensorPeripheral Object
 */
- (BLEHRSensorPeripheral *) initWithPeripheral:(CBPeripheral *)aPeripheral delegate:(id<BLEHRSensorPeripheralDelegate>)aDelegate;

/**
 *  开始扫描设备上的Service信息
 */
- (void)scanServices;

/**
 *  清理资源
 */
- (void)cleanup;

@end
