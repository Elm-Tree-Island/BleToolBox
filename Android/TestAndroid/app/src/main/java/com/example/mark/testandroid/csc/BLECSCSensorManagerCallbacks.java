package com.example.mark.testandroid.csc;

import com.example.mark.testandroid.common.BLESensorCallbacks;

/**
 * Cycling Speed and Cadence callbacks.
 *
 * Created by Mark Chen on 17/05/2017.
 */

public interface BLECSCSensorManagerCallbacks extends BLESensorCallbacks {

    public void onSpeedMeasurementReceived(final int wheelRevolutions, final int wheelCrankEventTime);

    public void onCadenceMeasurementReceived(final int crankRevolutions, final int lastCrankEventTime);

}
