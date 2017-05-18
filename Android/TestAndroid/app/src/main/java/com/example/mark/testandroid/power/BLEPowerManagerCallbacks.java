package com.example.mark.testandroid.power;

import com.example.mark.testandroid.common.BLESensorCallbacks;

/**
 * Created by Mark Chen on 17/05/2017.
 */

public interface BLEPowerManagerCallbacks extends BLESensorCallbacks {

    public void onPowerReceived(int power);
}
