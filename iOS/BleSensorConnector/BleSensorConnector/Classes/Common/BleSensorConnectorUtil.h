//
//  BleSensorConnectorUtil.h
//  BleSensorConnector
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define UUID_GATT_OFFICIAL_ADV_CYCLING_POWER                    @"1818"//@"00001818-0000-1000-8000-00805F9B34FB"
#define UUID_GATT_OFFICIAL_ADV_CYCLING_SPEED_AND_CADENCE        @"1816"//@"00001816-0000-1000-8000-00805F9B34FB"
#define UUID_GATT_OFFICIAL_ADV_HEART_RATE                       @"180D"//@"0000180D-0000-1000-8000-00805F9B34FB"

#define UUID_GATT_OFFICIAL_SERVICE_CYCLING_POWER                @"00001818-0000-1000-8000-00805F9B34FB"
#define UUID_GATT_OFFICIAL_SERVICE_CYCLING_SPEED_AND_CADENCE    @"00001816-0000-1000-8000-00805F9B34FB"
#define UUID_GATT_OFFICIAL_SERVICE_HEART_RATE                   @"0000180D-0000-1000-8000-00805F9B34FB"

// Characteristic
#define UUID_GATT_OFFICIAL_CHARACTERISTIC_CYCLING_POWER         @"00002A63-0000-1000-8000-00805F9B34FB"
#define UUID_GATT_OFFICIAL_CHARACTERISTIC_CSC                   @"00002A5B-0000-1000-8000-00805F9B34FB"
#define UUID_GATT_OFFICIAL_CHARACTERISTIC_HR                    @"00002A37-0000-1000-8000-00805F9B34FB"


@interface BleSensorConnectorUtil : NSObject

+ (CBUUID *) UUIDAdvPower;

+ (CBUUID *) UUIDAdvCSC;

+ (CBUUID *) UUIDAdvHR;

+ (CBUUID *) UUIDServicePower;

+ (CBUUID *) UUIDServiceCSC;

+ (CBUUID *) UUIDServiceHR;

+ (CBUUID *) UUIDCharacteristicPower;

+ (CBUUID *) UUIDCharacteristicCSC;

+ (CBUUID *) UUIDCharacteristicHR;

@end
