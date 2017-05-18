//
//  BLE3rdPartySensorPeripheral.h
//  Vodka
//
//  Created by Mark C.J. on 11/05/2017.
//  Copyright © 2017 Beijing Beast Technology Co.,Ltd. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@protocol BLEPowerSensorPeripheralDelegate <NSObject>

- (void) didPowerDataReceived:(int)powerInWatts;

@end

@interface BLEPowerSensorPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic, weak) id <BLEPowerSensorPeripheralDelegate> delegate;

@property (nonatomic, strong) CBPeripheral *pwrPeripheral;              // PWR Peripheral
@property (nonatomic, strong) CBService *pwrMeterService;               // PWR Service
@property (nonatomic, strong) CBCharacteristic *pwrCharacteristic;      // PWR Characteristic


/**
 <#Description#>

 @param aPeripheral <#aPeripheral description#>
 @param aDelegate <#aDelegate description#>
 @return <#return value description#>
 */
- (BLEPowerSensorPeripheral *) initWithPeripheral:(CBPeripheral *)aPeripheral delegate:(id<BLEPowerSensorPeripheralDelegate>)aDelegate;

/**
 *  开始扫描设备上的Service信息
 */
- (void)scanServices;

/**
 *  清理资源
 */
- (void)cleanup;

@end
