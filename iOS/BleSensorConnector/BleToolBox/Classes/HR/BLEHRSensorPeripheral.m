//
//  BLEHRSensorPeripheral.m
//  BleToolBox
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#import "BLEHRSensorPeripheral.h"
#import "BleSensorConnectorUtil.h"

@implementation BLEHRSensorPeripheral

/**
 Initialize
 
 @param aPeripheral CBPeripheral Object
 @param aDelegate   Data receive delegate
 @return BLEHRSensorPeripheral Object
 */
- (BLEHRSensorPeripheral *) initWithPeripheral:(CBPeripheral *)aPeripheral delegate:(id<BLEHRSensorPeripheralDelegate>)aDelegate {
    self = [super init];
    
    if (self) {
        self.peripheral = aPeripheral;
        self.peripheral.delegate = self;
        self.delegate = aDelegate;
    }
    
    return self;
}

#pragma mark - 工具方法

- (void)scanServices {
    [self.peripheral discoverServices:@[[BleSensorConnectorUtil UUIDServiceHR]]];
}

- (void)cleanup {
    if (!self.peripheral) {
        return;
    }
    
    self.service = nil;
    self.characteristic = nil;
    self.peripheral = nil;
}

#pragma mark - CBPeripheralDelegate 方法

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"[ERROR] Discover Service Error : %@", error);
        return;
    }
    
    // Scan all services
    for (CBService *s in [aPeripheral services]) {
        NSLog(@"Discover Service - UUID = %@", s.UUID);
        if ([s.UUID isEqual:[BleSensorConnectorUtil UUIDServiceHR]]) {
            self.service = s;
            // Find Characteristic
            [self.peripheral discoverCharacteristics:@[[BleSensorConnectorUtil UUIDCharacteristicHR]] forService:self.service];
            
            break;
        }
    }
}

/*
 *  Scan Characteristic
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
        NSLog(@"发现 Sensor characteristic， UUID = %@", c.UUID);
        if ([c.UUID isEqual:[BleSensorConnectorUtil UUIDCharacteristicHR]]) {
            self.characteristic = c;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
            break;
        }
    }
}

/*!
 *  Read data update
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
        if (length > 0) {
            const uint8_t *byteArray = (uint8_t *)[data bytes];
            uint16_t hrValue = 0;
            
            if ((byteArray[0] & 0x01) == 0) {
                hrValue = byteArray[1];
            } else {
                hrValue = CFSwapInt16HostToLittle(*(uint16_t *)(&byteArray[1]));
            }

            NSMutableString *strResult = [[NSMutableString alloc] init];
            for (int i = 0; i < [data length]; i++) {
                [strResult appendFormat:@"%02X ", byteArray[i]];
            }
            NSLog(@"RECEIVE %dB data：%@, characteristic = %@", length, strResult, characteristic.UUID.UUIDString);

            // Call the callback
            if (self.delegate != nil) {
                [self.delegate didHRDataReceived:hrValue];
            }
        }
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
