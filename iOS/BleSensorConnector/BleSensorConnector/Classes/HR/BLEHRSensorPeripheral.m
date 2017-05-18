//
//  BLEHRSensorPeripheral.m
//  BleSensorConnector
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
/**
 *  开始扫描设备上的Service信息
 */
- (void)scanServices {
    [self.peripheral discoverServices:@[[BleSensorConnectorUtil UUIDServiceHR]]];
}

/**
 *  清理资源
 */
- (void)cleanup {
    if (!self.peripheral) {
        return;
    }
    
    self.service = nil;
    self.characteristic = nil;
    self.peripheral = nil;
}

#pragma mark - CBPeripheralDelegate 方法

/*
 *  发现Service
 */
- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"[ERROR] Discover Service Error : %@", error);
        return;
    }
    
    // 解析所有Services
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
        NSLog(@"发现 Sensor characteristic， UUID = %@", c.UUID);
        if ([c.UUID isEqual:[BleSensorConnectorUtil UUIDCharacteristicHR]]) {
            self.characteristic = c;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.characteristic];
            break;
        }
    }
}

/*!
 *  读取数据更新
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
        
        NSLog(@"收到的 %d 字节数据：%@, characteristic = %@", length, strResult, characteristic.UUID.UUIDString);
        int16_t pwrValueInWatts = *(int16_t *)(byteArray + 2);
        NSLog(@"HR ：%d", pwrValueInWatts);
        //        [self.delegate didReceiveData:strResult];
    }
}

/**
 *  接收Notification状态更新
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic: (CBCharacteristic *)characteristic error:(NSError *)error {
    // Check Error.
    if (error) {
        NSLog(@"[ERROR] 接收Notification状态更新 失败，characteristic = %@, "
              @"error = %@", characteristic, [error localizedDescription]);
        return;
    }
}

@end
