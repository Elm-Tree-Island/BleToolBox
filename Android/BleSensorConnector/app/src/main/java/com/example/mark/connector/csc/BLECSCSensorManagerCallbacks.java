package com.example.mark.connector.csc;

import com.example.mark.connector.common.BLESensorCallbacks;

/**
 * Cycling Speed and Cadence callbacks.
 *
 * Created by Mark Chen on 17/05/2017.
 */

public interface BLECSCSensorManagerCallbacks extends BLESensorCallbacks {

    /**
     * Speed Update, Only Speed Data update
     *
     * @param wheelRevolutions          Wheel revolutions count
     * @param wheelCrankEventTime       Last wheel event time, unix time.
     */
    void onSpeedMeasurementReceived(final int wheelRevolutions, final int wheelCrankEventTime);

    /**
     * Cadence Update, only cadence data update
     *
     * @param crankRevolutions          Cumulative Crank Revolutions
     * @param lastCrankEventTime        Last Event Time
     */
    void onCadenceMeasurementReceived(final int crankRevolutions, final int lastCrankEventTime);
}
