//
//  BLE3rdPartyCentralManager.m
//  Vodka
//
//  Created by Mark C.J. on 11/05/2017.
//  Copyright © 2017 CHEN JIAN <chenjian345@gmail.com> All rights reserved.
//

#import "BLESensorCentralManager.h"
#import "BleSensorConnectorUtil.h"

@interface BLESensorCentralManager() <CBCentralManagerDelegate, CBPeripheralDelegate>

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
        // Scan device in the main thread
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:@YES forKey:CBCentralManagerOptionShowPowerAlertKey]];
        self.sensorPowerPeripheral = nil;
    }
    
    return self;
}

/**
 Check if BLE is enabled.

 @return BOOL
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
    NSLog(@"Current Bluetooth State = %ld", (long)central.state);
    if (central.state == CBManagerStatePoweredOn) {
        [self scanSensors];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // Device name, e.g. Wahoo KICKR SNAP 8E1D
    NSString *localName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    // Service UUIDs
    NSArray *arrServices = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    
    if (localName != nil && localName.length > 0) {
        NSLog(@"FOUNT Device %@", localName);
    }

    if (arrServices.count > 0) {
        for (CBUUID *service in arrServices) {
            if ([service isEqual:[BleSensorConnectorUtil UUIDServicePower]]) {
                NSLog(@"Found BLE PWOER METER Sensor!!!");
                if (self.sensorPowerPeripheral == nil) {
                    self.sensorPowerPeripheral = [[BLEPowerSensorPeripheral alloc] initWithPeripheral:peripheral delegate:self.powerDelegate];
                }
                self.foundPeripheralType = UUID_GATT_OFFICIAL_ADV_CYCLING_POWER;
                [self.centralManager connectPeripheral:peripheral options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES] }];
                break;
                
            } else if ([service isEqual:[BleSensorConnectorUtil UUIDServiceCSC]]) {
                NSLog(@"Found BLE Speed & Cadence Sensor!!!");
                if (self.sensorCscPeripheral == nil) {
                    self.sensorCscPeripheral = [[BLECSCSensorPeripheral alloc] initWithPeripheral:peripheral delegate:self.cscDelegate];
                }
                self.foundPeripheralType = UUID_GATT_OFFICIAL_ADV_CYCLING_SPEED_AND_CADENCE;
                [self.centralManager connectPeripheral:peripheral options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: [NSNumber numberWithBool:YES] }];
                break;

            } else if ([service isEqual:[BleSensorConnectorUtil UUIDServiceHR]]) {
                NSLog(@"Found BLE HR METER Sensor!!!");
                if (self.sensorHrPeripheral == nil) {
                    self.sensorHrPeripheral = [[BLEHRSensorPeripheral alloc] initWithPeripheral:peripheral delegate:self.hrDelegate];
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
    NSLog(@"BLE - CONNECTED TO : %@", peripheral.name);
    
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
        NSLog(@"[ERROR] CONNECT DEVICE FAILED， error = %@", error.localizedDescription);
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
    NSLog(@"START SCAN ...");
    NSArray *arrServices = @[[BleSensorConnectorUtil UUIDAdvHR], [BleSensorConnectorUtil UUIDAdvCSC], [BleSensorConnectorUtil UUIDAdvPower]];
    [self.centralManager scanForPeripheralsWithServices:arrServices options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
}

@end
