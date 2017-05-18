//
//  BLE3rdPartySensorPeripheral.m
//  Vodka
//
//  Created by Mark C.J. on 11/05/2017.
//  Copyright © 2017 Beijing Beast Technology Co.,Ltd. All rights reserved.
//

#import "BLE3rdPartySensorPeripheral.h"

@implementation BLE3rdPartySensorPeripheral

/**
 初始化Peripheral方法

 @param aPeripheral
 @param aDelegate
 @return
 */
- (BLE3rdPartySensorPeripheral *) initWithPeripheral:(CBPeripheral *)aPeripheral delegate:(id<BLE3rdPartySensorPeripheralDelegate>)aDelegate {
    self = [super init];
    
    if (self) {
        self.pwrPeripheral = aPeripheral;
        self.pwrPeripheral.delegate = self;
        self.delegate = aDelegate;
    }
    
    return self;
}

#pragma mark - 工具方法
/**
 *  开始扫描设备上的Service信息
 */
- (void)scanServices {
    [self.pwrPeripheral discoverServices:nil];
}

/**
 *  清理资源
 */
- (void)cleanup {
    if (!self.pwrPeripheral) {
        return;
    }
    
    self.pwrMeterService = nil;
    self.pwrCharacteristic = nil;
    self.pwrPeripheral = nil;
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
        NSLog(@"发现Service - UUID = %@", s.UUID);
        
        // 如果是Vodka的Service UUID
        if ([s.UUID isEqual:[CBUUID UUIDWithString:GATT_OFFICIAL_UUID_SERVICE_CYCLING_POWER]]) {
            NSLog(@"\n\n\n--------------- 发现 Vodka Service --------------\n");
            self.pwrMeterService = s;
            
            // 查询接收数据的Characteristic
            
            NSArray *characteristicsForDiscover = @[
                                                    [CBUUID UUIDWithString:GATT_OFFICIAL_UUID_CHARACTERISTIC_CYCLING_POWER]
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
        NSLog(@"发现 Sensor characteristic， UUID = %@", c.UUID);
        if ([c.UUID isEqual:[CBUUID UUIDWithString:GATT_OFFICIAL_UUID_CHARACTERISTIC_CYCLING_POWER]]) {
            self.pwrCharacteristic = c;
            [self.pwrPeripheral setNotifyValue:YES forCharacteristic:self.pwrCharacteristic];
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
        
        // 功率
        int16_t pwrValueInWatts = *(int16_t *)(byteArray + 2);
        NSLog(@"功率 ：%d w", pwrValueInWatts);
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

/**
 *  接收写入结果
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"[ERROR] 写入数据失败, error = %@, characteristic = %@", error.localizedDescription, characteristic.UUID.UUIDString);
        return;
    } else {
        NSLog(@"写入数据成功, characteristic UUID = %@", characteristic.UUID.UUIDString);
    }
}

@end
