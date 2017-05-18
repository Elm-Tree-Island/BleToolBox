package com.example.mark.connector.csc;

import com.example.mark.connector.common.BLESensorCallbacks;

/**
 * Cycling Speed and Cadence callbacks.
 *
 * Created by Mark Chen on 17/05/2017.
 */

public interface BLECSCSensorManagerCallbacks extends BLESensorCallbacks {

    public void onSpeedMeasurementReceived(final int wheelRevolutions, final int wheelCrankEventTime);

    public void onCadenceMeasurementReceived(final int crankRevolutions, final int lastCrankEventTime);

}
