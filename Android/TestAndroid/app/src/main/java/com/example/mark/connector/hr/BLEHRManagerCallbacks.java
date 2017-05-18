package com.example.mark.connector.hr;

import com.example.mark.connector.common.BLESensorCallbacks;

/**
 * Created by Mark Chen on 17/05/2017.
 */

public interface BLEHRManagerCallbacks extends BLESensorCallbacks {
    /**
     * Called when the heart rate changed
     */
    public void onHeartRateValueReceived(final int hrValue);

}
