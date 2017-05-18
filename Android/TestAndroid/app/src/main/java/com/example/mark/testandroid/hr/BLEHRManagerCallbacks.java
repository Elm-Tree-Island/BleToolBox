package com.example.mark.testandroid.hr;

import com.example.mark.testandroid.common.BLESensorCallbacks;

import java.util.Calendar;

/**
 * Created by Mark Chen on 17/05/2017.
 */

public interface BLEHRManagerCallbacks extends BLESensorCallbacks {
    /**
     * Called when the heart rate changed
     */
    public void onHeartRateValueReceived(final int hrValue);

}
