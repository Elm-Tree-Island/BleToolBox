//
//  BLE3rdPartySensorPeripheral.m
//  Vodka
//
//  Created by Mark C.J. on 11/05/2017.
//  Copyright © 2017 CHEN JIAN <chenjian345@gmail.com> All rights reserved.
//

#import "BLEPowerSensorPeripheral.h"
#import "BleSensorConnectorUtil.h"

@implementation BLEPowerSensorPeripheral

/**
 Initalization Method

 @param aPeripheral <#aPeripheral description#>
 @param aDelegate <#aDelegate description#>
 @return <#return value description#>
 */
- (BLEPowerSensorPeripheral *) initWithPeripheral:(CBPeripheral *)aPeripheral delegate:(id<BLEPowerSensorPeripheralDelegate>)aDelegate {
    self = [super init];
    
    if (self) {
        self.pwrPeripheral = aPeripheral;
        self.pwrPeripheral.delegate = self;
        self.delegate = aDelegate;
    }
    
    return self;
}

#pragma mark - 工具方法
- (void)scanServices {
    [self.pwrPeripheral discoverServices:@[[BleSensorConnectorUtil UUIDServicePower]]];
}

/**
 *  Clean up resource
 */
- (void)cleanup {
    if (!self.pwrPeripheral) {
        return;
    }
    
    self.pwrMeterService = nil;
    self.pwrCharacteristic = nil;
    self.pwrPeripheral = nil;
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"[ERROR] Discover Service Error : %@", error);
        return;
    }
    
    for (CBService *s in [aPeripheral services]) {
        NSLog(@"FOUND Service - UUID = %@", s.UUID);
        
        // 如果是Vodka的Service UUID
        if ([s.UUID isEqual:[BleSensorConnectorUtil UUIDServicePower]]) {
            self.pwrMeterService = s;
            NSArray *characteristicsForDiscover = @[
                                                    [BleSensorConnectorUtil UUIDServicePower]
                                                    ];
            [self.pwrPeripheral discoverCharacteristics: characteristicsForDiscover forService:self.pwrMeterService];
            
            break;
        }
    }
}

/*
 *  发现Characteristic
 */
- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)aService error:(NSError *)error {
    if (error) {
        NSLog(@"[Error] Discovering characteristics Error : %@", error);
        if (error) {
            [self cleanup];
        }
        return;
    }
    
    for (CBCharacteristic *c in [aService characteristics]) {
        NSLog(@"FOUND Sensor characteristic， UUID = %@", c.UUID);
        if ([c.UUID isEqual:[BleSensorConnectorUtil UUIDServicePower]]) {
            self.pwrCharacteristic = c;
            [self.pwrPeripheral setNotifyValue:YES forCharacteristic:self.pwrCharacteristic];
            break;
        }
    }
}

/*!
 *  Read the data update
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the
 *failure.
 *
 *  @discussion				This method is invoked after a @link
 *readValueForCharacteristic: @/link call, or upon receipt of a
 *notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    @synchronized(self) {
        if (error) {
            NSLog(@"[Error] Receiving notification for characteristic Error: "
                       @"characteristic - %@: error - %@", characteristic, error);
            [self cleanup];
            return;
        }
        
        NSData *data = [characteristic value];
        int length = (int)data.length;
        assert(data != nil);
        uint8_t *byteArray = (uint8_t *)[data bytes];
        assert(data != nil);
        
        NSMutableString *strResult = [[NSMutableString alloc] init];
        
        for (int i = 0; i < [data length]; i++) {
            [strResult appendFormat:@"%02X ", byteArray[i]];
        }

        NSLog(@"RECEIVE %dB data：%@, characteristic = %@", length, strResult, characteristic.UUID.UUIDString);
        
        int16_t pwrValueInWatts = *(int16_t *)(byteArray + 2);
        NSLog(@"Power ：%d w", pwrValueInWatts);
//        [self.delegate didReceiveData:strResult];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic: (CBCharacteristic *)characteristic error:(NSError *)error {
    // Check Error.
    if (error) {
        NSLog(@"[ERROR] Receive Notification state update - FAILED，characteristic = %@, "
                   @"error = %@", characteristic, [error localizedDescription]);
        return;
    }
}

@end
