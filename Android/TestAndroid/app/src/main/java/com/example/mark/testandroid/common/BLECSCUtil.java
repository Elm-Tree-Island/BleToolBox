package com.example.mark.testandroid.common;

/**
 * Created by Mark Chen on 16/05/2017.
 */

public class BLECSCUtil {

    private static int mFirstWheelRevolutions;
    private static int mLastWheelEventTime;
    private static int mLastWheelRevolutions;
    private static double mWheelCadence;

    private static int mLastCrankEventTime;
    private static int mLastCrankRevolutions;

    /**
     * Calculate the speed according to wheel diameter, wheel revolutions and last wheel event time.
     * Unit is m/s
     *
     * @param wheelRevolutions          Read from the BLE sensor, indicate the current wheel revolutions
     * @param lastWheelEventTime        Read from the BLE sensor, indicate the current data trigger time, unit ms
     * @param wheelCircumferenceInMM    Set by user, wheel circumference, unit mm.
     * @return Double
     */
    public static double calculateSpeed(final int wheelRevolutions, final int lastWheelEventTime, final float wheelCircumferenceInMM) {
        float speed = 0f;
        if (mFirstWheelRevolutions < 0)
            mFirstWheelRevolutions = wheelRevolutions;

        if (mLastWheelEventTime == lastWheelEventTime)
            return speed;

        if (mLastWheelRevolutions >= 0) {
            float timeDifference = 0;
            if (lastWheelEventTime < mLastWheelEventTime)
                timeDifference = (65535 + lastWheelEventTime - mLastWheelEventTime) / 1024.0f;  // Unit second
            else
                timeDifference = (lastWheelEventTime - mLastWheelEventTime) / 1024.0f;  // Unit second
            final float distanceDifference = (wheelRevolutions - mLastWheelRevolutions) * wheelCircumferenceInMM / 1000.0f; // Unit [m]
            final float totalDistance = (float) wheelRevolutions * (float) wheelCircumferenceInMM / 1000.0f; // Unit [m]
            final float distance = (float) (wheelRevolutions - mFirstWheelRevolutions) * (float) wheelCircumferenceInMM / 1000.0f; // [m]
            speed = distanceDifference / timeDifference;    // Unit [m/s]
            mWheelCadence = (wheelRevolutions - mLastWheelRevolutions) * 60.0f / timeDifference;

        }
        mLastWheelRevolutions = wheelRevolutions;
        mLastWheelEventTime = lastWheelEventTime;

        return speed;
    }

    /**
     * Calculate the sensor cadence
     *
     * @param crankRevolutions      Crank revolution count
     * @param lastCrankEventTime    Last crank data trigger event time.
     * @return Double, actually int is enough.
     */
    public static double calculateCadence(int crankRevolutions, int lastCrankEventTime) {
        float crankCadence = 0;
        if (mLastCrankEventTime == lastCrankEventTime) {
            return crankCadence;
        }

        if (mLastCrankRevolutions >= 0) {
            float timeDifference = 0;
            if (lastCrankEventTime < mLastCrankEventTime)
                timeDifference = (65535 + lastCrankEventTime - mLastCrankEventTime) / 1024.0f; // [s]
            else
                timeDifference = (lastCrankEventTime - mLastCrankEventTime) / 1024.0f; // [s]

            // 计算踏频
            crankCadence = (crankRevolutions - mLastCrankRevolutions) * 60.0f / timeDifference;
            if (crankCadence > 0) {
                // 计算齿比
                final double gearRatio = mWheelCadence / crankCadence;
            }
        }
        mLastCrankRevolutions = crankRevolutions;
        mLastCrankEventTime = lastCrankEventTime;

        return crankCadence;
    }
}
