//
//  BleSensorConnectorUtil.m
//  BleSensorConnector
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#import "BleSensorConnectorUtil.h"

@implementation BleSensorConnectorUtil

+ (CBUUID *) UUIDAdvPower {
    return [CBUUID UUIDWithString:UUID_GATT_OFFICIAL_ADV_CYCLING_POWER];
}

+ (CBUUID *) UUIDAdvCSC {
    return [CBUUID UUIDWithString:UUID_GATT_OFFICIAL_ADV_CYCLING_SPEED_AND_CADENCE];
}

+ (CBUUID *) UUIDAdvHR {
    return [CBUUID UUIDWithString:UUID_GATT_OFFICIAL_ADV_HEART_RATE];
}

+ (CBUUID *) UUIDServicePower {
    return [CBUUID UUIDWithString:UUID_GATT_OFFICIAL_SERVICE_CYCLING_POWER];
}

+ (CBUUID *) UUIDServiceCSC {
    return [CBUUID UUIDWithString:UUID_GATT_OFFICIAL_SERVICE_CYCLING_SPEED_AND_CADENCE];
}

+ (CBUUID *) UUIDServiceHR {
    return [CBUUID UUIDWithString:UUID_GATT_OFFICIAL_SERVICE_HEART_RATE];
}

/**
 <#Description#>

 @return <#return value description#>
 */
+ (CBUUID *) UUIDCharacteristicPower {
    return [CBUUID UUIDWithString:UUID_GATT_OFFICIAL_CHARACTERISTIC_CYCLING_POWER];
}

/**
 <#Description#>

 @return <#return value description#>
 */
+ (CBUUID *) UUIDCharacteristicCSC {
    return [CBUUID UUIDWithString:UUID_GATT_OFFICIAL_CHARACTERISTIC_CSC];
}

/**
 <#Description#>

 @return <#return value description#>
 */
+ (CBUUID *) UUIDCharacteristicHR {
    return [CBUUID UUIDWithString:UUID_GATT_OFFICIAL_CHARACTERISTIC_HR];
}

@end
