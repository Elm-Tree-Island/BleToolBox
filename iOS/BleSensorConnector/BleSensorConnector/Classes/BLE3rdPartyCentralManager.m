//
//  BLE3rdPartyCentralManager.m
//  Vodka
//
//  Created by Mark C.J. on 11/05/2017.
//  Copyright © 2017 Beijing Beast Technology Co.,Ltd. All rights reserved.
//

#import "BLE3rdPartyCentralManager.h"

@interface BLE3rdPartyCentralManager() <CBCentralManagerDelegate, CBPeripheralDelegate, BLE3rdPartySensorPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) BLE3rdPartySensorPeripheral *sensorPeripheral;

@property (nonatomic, assign) CYCLING_SENSOR_TYPE sensorType;

@end


@implementation BLE3rdPartyCentralManager

instance_implementation(BLE3rdPartyCentralManager, defaultManager)

- (id)init {
    self = [super init];
    
    if (self) {
        // 在主线程中进行扫描
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:@YES forKey:CBCentralManagerOptionShowPowerAlertKey]];
        self.sensorPeripheral = nil;
    }
    
    return self;
}

// 手机是否开启蓝牙，返回蓝牙使能状态
- (BOOL)isBLEEnabled {
    return (self.centralManager.state == CBCentralManagerStatePoweredOn);
}

/**
 *  Start Connect the SpeedX BLE Devices.
 */
- (void)scan {
    NSLog(@"=============== 开始扫描蓝牙设备 ===============");
    
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
    } else {
        NSLog(@"蓝牙未开启，当前蓝牙状态 %ld", (long)self.centralManager.state);
    }
}

- (BOOL) disconnect {
    [self.centralManager cancelPeripheralConnection:self.sensorPeripheral.pwrPeripheral];
    return YES;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"当前蓝牙状态为 = %ld", (long)central.state);
    if (central.state == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // 读出广播中的设备名，例如Wahoo骑行台：KICKR SNAP 8E1D
    NSString *localName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    // 读出广播中的能提供的Service UUID,包括功率等
    NSArray *arrServices = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];

    if (arrServices.count > 0) {
        for (CBUUID *service in arrServices) {
            if ([service.UUIDString isEqualToString:GATT_OFFICIAL_UUID_SERVICE_CYCLING_POWER] ) {
                NSLog(@"找到BLE PWOER METER Sensor!!!");
                self.sensorType = CYCLING_SENSOR_TYPE_PWR_METER;
            } else if ([service.UUIDString isEqualToString:GATT_OFFICIAL_UUID_SERVICE_CYCLING_SPEED_AND_CADENCE]) {
                NSLog(@"找到BLE Speed & Cadence Sensor!!!");
                self.sensorType = CYCLING_SENSOR_TYPE_SPEED_AND_CADENCE;
            } else if ([service.UUIDString isEqualToString:GATT_OFFICIAL_UUID_SERVICE_HEART_RATE]) {
                NSLog(@"找到BLE HR METER Sensor!!!");
                self.sensorType = CYCLING_SENSOR_TYPE_HR_METER;
            }
        }
    }

    if (self.sensorType != 0 || [localName isEqualToString:@"KICKR SNAP 8E1D"]) {
        NSLog(@"找到了");
        [self.centralManager stopScan];
        
        self.sensorPeripheral = [[BLE3rdPartySensorPeripheral alloc] initWithPeripheral:peripheral delegate:self];
        [self.centralManager connectPeripheral:peripheral options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES] }];
    }
}

// 该方法为主线程方法
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"BLE - 已连接到 peripheral : %@", peripheral.name);
    // 保存把立信息到本地
    NSString *strUUID = [peripheral.identifier UUIDString];
    
    if (!strUUID || strUUID.length == 0) {
        NSLog(@"[Error] BLE UUID is Empty.");
        return;
    }
    
    // 调用Peripheral方法，搜索Services
    [self.sensorPeripheral scanServices];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    if (error) {
        NSLog(@"[ERROR] 连接设备失败， error = %@", error.localizedDescription);
        // 清理资源
        // TBD
        
        if (self.sensorPeripheral) {
            [self.sensorPeripheral cleanup];
            self.sensorPeripheral = nil;
        }
    }
}


@end
