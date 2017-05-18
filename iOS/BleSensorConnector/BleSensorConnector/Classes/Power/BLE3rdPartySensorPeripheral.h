//
//  BLE3rdPartySensorPeripheral.h
//  Vodka
//
//  Created by Mark C.J. on 11/05/2017.
//  Copyright © 2017 Beijing Beast Technology Co.,Ltd. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "BLE3rdPartySensorDefinitions.h"

@protocol BLE3rdPartySensorPeripheralDelegate <NSObject>

@end

typedef enum : NSUInteger {
    CYCLING_SENSOR_TYPE_PWR_METER           = 0x01,
    //    CYCLING_SENSOR_TYPE_SPEED,
    //    CYCLING_SENSOR_TYPE_CADENCE,
    CYCLING_SENSOR_TYPE_SPEED_AND_CADENCE,
    CYCLING_SENSOR_TYPE_HR_METER,
} CYCLING_SENSOR_TYPE;

@interface BLE3rdPartySensorPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic, weak) id <BLE3rdPartySensorPeripheralDelegate> delegate;

@property (nonatomic, strong) CBPeripheral *pwrPeripheral;              // PWR Peripheral
@property (nonatomic, strong) CBService *pwrMeterService;               // PWR Service
@property (nonatomic, strong) CBCharacteristic *pwrCharacteristic;      // PWR Characteristic


/**
 初始化Peripheral方法
 
 @param aPeripheral
 @param aDelegate
 @return
 */
- (BLE3rdPartySensorPeripheral *) initWithPeripheral:(CBPeripheral *)aPeripheral delegate:(id<BLE3rdPartySensorPeripheralDelegate>)aDelegate;

/**
 *  开始扫描设备上的Service信息
 */
- (void)scanServices;

/**
 *  清理资源
 */
- (void)cleanup;

@end
