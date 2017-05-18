//
//  BLE3rdPartyCentralManager.m
//  Vodka
//
//  Created by Mark C.J. on 11/05/2017.
//  Copyright © 2017 Beijing Beast Technology Co.,Ltd. All rights reserved.
//

#import "BLESensorCentralManager.h"
#import "BleSensorConnectorUtil.h"

#import "BLEPowerSensorPeripheral.h"
#import "BLECSCSensorPeripheral.h"
#import "BLEHRSensorPeripheral.h"

@interface BLESensorCentralManager() <CBCentralManagerDelegate, CBPeripheralDelegate, BLEPowerSensorPeripheralDelegate, BLECSCSensorPeripheralDelegate, BLEHRSensorPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) BLEPowerSensorPeripheral *sensorPowerPeripheral;
@property (nonatomic, strong) BLECSCSensorPeripheral *sensorCscPeripheral;
@property (nonatomic, strong) BLEHRSensorPeripheral *sensorHrPeripheral;

@property (nonatomic, strong) NSString *foundPeripheralType;

@end


@implementation BLESensorCentralManager

instance_implementation(BLESensorCentralManager, defaultManager)

- (id)init {
    self = [super init];
    
    if (self) {
        // 在主线程中进行扫描
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:@YES forKey:CBCentralManagerOptionShowPowerAlertKey]];
        self.sensorPowerPeripheral = nil;
    }
    
    return self;
}

// 手机是否开启蓝牙，返回蓝牙使能状态

/**
 Check

 @return <#return value description#>
 */
- (BOOL)isBLEEnabled {
    return (self.centralManager.state == CBCentralManagerStatePoweredOn);
}

/**
 *  Start Connect the SpeedX BLE Devices.
 */
- (void)scan {
    NSLog(@"=============== Start Scan BLE Sensors ===============");
    
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self scanSensors];
    } else {
        NSLog(@"Bluetooth state changed, now state is %ld", (long)self.centralManager.state);
    }
}

- (BOOL) disconnect {
    [self.centralManager cancelPeripheralConnection:self.sensorPowerPeripheral.pwrPeripheral];
    return YES;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"当前蓝牙状态为 = %ld", (long)central.state);
    if (central.state == CBManagerStatePoweredOn) {
        [self scanSensors];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // 读出广播中的设备名，例如Wahoo骑行台：KICKR SNAP 8E1D
    NSString *localName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    // 读出广播中的能提供的Service UUID,包括功率等
    NSArray *arrServices = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    
    if (localName != nil && localName.length > 0) {
        NSLog(@"搜到设备 %@", localName);
    }

    if (arrServices.count > 0) {
        for (CBUUID *service in arrServices) {
            if ([service isEqual:[BleSensorConnectorUtil UUIDServicePower]]) {
                NSLog(@"Found BLE PWOER METER Sensor!!!");
                if (self.sensorPowerPeripheral == nil) {
                    self.sensorPowerPeripheral = [[BLEPowerSensorPeripheral alloc] initWithPeripheral:peripheral delegate:self];
                }
                self.foundPeripheralType = UUID_GATT_OFFICIAL_ADV_CYCLING_POWER;
                [self.centralManager connectPeripheral:peripheral options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES] }];
                break;
                
            } else if ([service isEqual:[BleSensorConnectorUtil UUIDServiceCSC]]) {
                NSLog(@"Found BLE Speed & Cadence Sensor!!!");
                if (self.sensorCscPeripheral == nil) {
                    self.sensorCscPeripheral = [[BLECSCSensorPeripheral alloc] initWithPeripheral:peripheral delegate:self];
                }
                self.foundPeripheralType = UUID_GATT_OFFICIAL_ADV_CYCLING_SPEED_AND_CADENCE;
                [self.centralManager connectPeripheral:peripheral options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES] }];
                break;

            } else if ([service isEqual:[BleSensorConnectorUtil UUIDServiceHR]]) {
                NSLog(@"Found BLE HR METER Sensor!!!");
                if (self.sensorHrPeripheral == nil) {
                    self.sensorHrPeripheral = [[BLEHRSensorPeripheral alloc] initWithPeripheral:peripheral delegate:self];
                }
                self.foundPeripheralType = UUID_GATT_OFFICIAL_ADV_HEART_RATE;
                [self.centralManager connectPeripheral:peripheral options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES] }];
                break;

            }
        }
    }
}

/**
 Called when peripheral connected.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"BLE - 已连接到 peripheral : %@", peripheral.name);
    
    if (peripheral.state == CBPeripheralStateConnected) {
        if ([self.foundPeripheralType isEqualToString:UUID_GATT_OFFICIAL_ADV_CYCLING_SPEED_AND_CADENCE]) {
            [self.sensorCscPeripheral scanServices];
        } else if ([self.foundPeripheralType isEqualToString:UUID_GATT_OFFICIAL_ADV_CYCLING_POWER]) {
            [self.sensorPowerPeripheral scanServices];
        } else if ([self.foundPeripheralType isEqualToString:UUID_GATT_OFFICIAL_ADV_HEART_RATE]) {
            [self.sensorHrPeripheral scanServices];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    if (error) {
        NSLog(@"[ERROR] 连接设备失败， error = %@", error.localizedDescription);
        // 清理资源
        
        if (self.sensorPowerPeripheral) {
            [self.sensorPowerPeripheral cleanup];
            self.sensorPowerPeripheral = nil;
        }
        
        if (self.sensorHrPeripheral) {
            [self.sensorHrPeripheral cleanup];
            self.sensorHrPeripheral = nil;
        }
        
        if (self.sensorCscPeripheral) {
            [self.sensorCscPeripheral cleanup];
            self.sensorCscPeripheral = nil;
        }
    }
}

#pragma mark - Tools Method
- (void)scanSensors {
    NSLog(@"开始扫描设备");
    NSArray *arrServices = @[[BleSensorConnectorUtil UUIDAdvHR], [BleSensorConnectorUtil UUIDAdvCSC], [BleSensorConnectorUtil UUIDAdvPower]];
    [self.centralManager scanForPeripheralsWithServices:arrServices options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
}

@end
