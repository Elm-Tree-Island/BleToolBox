package com.example.mark.connector.power;

import com.example.mark.connector.common.BLESensorCallbacks;

/**
 * Created by Mark Chen on 17/05/2017.
 */

public interface BLEPowerManagerCallbacks extends BLESensorCallbacks {

    public void onPowerReceived(int power);
}
