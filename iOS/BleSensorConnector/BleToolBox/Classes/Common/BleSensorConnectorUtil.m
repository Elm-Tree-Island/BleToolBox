//
//  BleSensorConnectorUtil.m
//  BleSensorConnector
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#import "BleSensorConnectorUtil.h"

@implementation BleSensorConnectorUtil

static int sFirstWheelRevolutions = -1;
static int sLastWheelEventTime;
static int sLastWheelRevolutions;
static double sWheelCadence;

static int sLastCrankEventTime;
static int sLastCrankRevolutions;


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

/**
 Calculate the speed value by the the CSC wheel revolutions, last wheel event time and wheel circumference.
 Unit: km/h
 
 @param wheelRevolutions wheel revolution count
 @param lastTime Wheel Last Event Time
 @param wheelCircumference Wheel last event time
 @return speed value in km/h
 */
+ (double)calculateSpeedWithWheelRev:(int)wheelRevolutions lastWheelEventTime:(int)lastTime wheelCircumferenceInMM:(int)wheelCircumference {
    double speedInKMPH = 0;
    if (sFirstWheelRevolutions < 0)
        sFirstWheelRevolutions = wheelRevolutions;
    
    if (sLastWheelEventTime == lastTime)
        return speedInKMPH;
    
    if (sLastWheelRevolutions >= 0) {
        float timeDifference = 0;
        if (lastTime < sLastWheelEventTime)
            timeDifference = (65535 + lastTime - sLastWheelEventTime) / 1024.0f;  // Unit second
        else
            timeDifference = (lastTime - sLastWheelEventTime) / 1024.0f;  // Unit second
        const float distanceDifference = (wheelRevolutions - sLastWheelRevolutions) * wheelCircumference / 1000.0f; // Unit [m]
//        const float totalDistance = (float) wheelRevolutions * (float) wheelCircumference / 1000.0f; // Unit [m]
//        const float distance = (float) (wheelRevolutions - sFirstWheelRevolutions) * (float) wheelCircumference / 1000.0f; // [m]
        speedInKMPH = distanceDifference / timeDifference;    // Unit [m/s]
        sWheelCadence = (wheelRevolutions - sLastWheelRevolutions) * 60.0f / timeDifference;
        
    }
    sLastWheelRevolutions = wheelRevolutions;
    sLastWheelEventTime = lastTime;
    
    return speedInKMPH * 3.6;   // Unit km/h
}

/**
 Calculate crank cadence by crank revolutions and last crank event time.
 Unit: RPM
 
 @param crankRevolutions int value, Crank revolution count get from CSC sensor
 @param lastTime Crank last event time, int.
 @return Unsigned int value.
 */
+ (uint)calculateCadenceWithCrankRev:(int)crankRevolutions lastCrankEventTime:(int)lastTime {
    float crankCadence = 0;
    if (sLastCrankEventTime == lastTime) {
        return crankCadence;
    }
    
    if (sLastCrankRevolutions >= 0) {
        float timeDifference = 0;
        if (lastTime < sLastCrankEventTime)
            timeDifference = (65535 + lastTime - sLastCrankEventTime) / 1024.0f; // [s]
        else
            timeDifference = (lastTime - sLastCrankEventTime) / 1024.0f; // [s]
        
        // 计算踏频
        crankCadence = (crankRevolutions - sLastCrankRevolutions) * 60.0f / timeDifference;
        if (crankCadence > 0) {
            // 计算齿比
            const double gearRatio = sWheelCadence / crankCadence;
        }
    }
    sLastCrankRevolutions = crankRevolutions;
    sLastCrankEventTime = lastTime;
    
    return crankCadence;
}

@end
