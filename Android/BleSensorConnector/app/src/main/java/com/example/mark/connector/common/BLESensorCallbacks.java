package com.example.mark.connector.common;

/**
 * Created by Mark Chen on 17/05/2017.
 */

public interface BLESensorCallbacks {

    /**
     * Called when the device has been connected. This does not mean that the application may start communication. A service discovery will be handled automatically after this call. Service discovery
     * may ends up with calling {@link #onServicesDiscovered()} or {@link #onDeviceNotSupported()} if required services have not been found.
     */
    public void onDeviceConnected();

    /**
     * Called when the device has disconnected (when the callback returned {@link BluetoothGattCallback#onConnectionStateChange(android.bluetooth.BluetoothGatt, int, int)} with state DISCONNECTED.
     */
    public void onDeviceDisconnected();

    /**
     * Called when an {@link BluetoothGatt#GATT_INSUFFICIENT_AUTHENTICATION} error occurred and the device bond state is NOT_BONDED
     */
    public void onBondingRequired();

    /**
     * Called when the device has been successfully bonded
     */
    public void onBonded();

    /**
     * Called when a BLE error has occurred
     *
     * @param message
     *            the error message
     * @param errorCode
     *            the error code
     */
    public void onError(final String message, final int errorCode);
}
