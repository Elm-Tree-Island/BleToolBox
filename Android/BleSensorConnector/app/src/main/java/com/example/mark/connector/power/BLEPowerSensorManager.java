package com.example.mark.connector.power;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.util.Log;

import com.example.mark.connector.common.BLESensorManager;
import com.example.mark.connector.common.BLESensorUtil;

import java.util.UUID;

/**
 * Created by Mark Chen on 17/05/2017.
 */

public class BLEPowerSensorManager extends BLESensorManager {
    private static final String TAG = "BLE-Power-Sensor";
    public static final String SERVICE_UUID_CYCLING_POWER = "00001818-0000-1000-8000-00805F9B34FB";
    private static final String CHARACTERISTIC_UUID_CYCLING_POWER = "00002A63-0000-1000-8000-00805F9B34FB";

    private BluetoothGatt mBtGattPower;
    private BLEPowerManagerCallbacks mCallbacks;

    private final BluetoothGattCallback mGattCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            super.onConnectionStateChange(gatt, status, newState);

            if (newState == BluetoothProfile.STATE_CONNECTED) {
                mBtGattPower.discoverServices();
                mCallbacks.onDeviceConnected();
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                Log.w(TAG, "Power Sensor disconnected");
                mCallbacks.onDeviceConnected();
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            super.onServicesDiscovered(gatt, status);

            if (status == BluetoothGatt.GATT_SUCCESS) {
                // 功率
                BluetoothGattService servicePower = mBtGattPower.getService(UUID.fromString(SERVICE_UUID_CYCLING_POWER));
                if (null != servicePower) {
                    Log.i(TAG, "Power Service Discovered - Success， status = " + status);
                    BluetoothGattCharacteristic characteristicPower = servicePower.getCharacteristic(UUID.fromString(CHARACTERISTIC_UUID_CYCLING_POWER));
                    if (null != characteristicPower) {
                        mBtGattPower.setCharacteristicNotification(characteristicPower, true);
                        BluetoothGattDescriptor firstDesc = characteristicPower.getDescriptor(BLESensorUtil.CLIENT_CHARACTERISTIC_CONFIG_DESCRIPTOR_UUID);
                        firstDesc.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        mBtGattPower.writeDescriptor(firstDesc);
                    }
                }
            } else {
                Log.w(TAG, "Power service discover failed, status = " + status);
            }
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            super.onCharacteristicChanged(gatt, characteristic);
            String uuid = characteristic.getUuid().toString();

//            byte[] data = characteristic.getValue();
//            final StringBuilder stringBuilder = new StringBuilder(data.length);
//            for(byte byteChar : data) {
//                stringBuilder.append(String.format("%02X ", byteChar));
//            }

            if (characteristic.getUuid().toString().equalsIgnoreCase(CHARACTERISTIC_UUID_CYCLING_POWER)) {
                // Read power data
                int flag = characteristic.getProperties();
                int power = characteristic.getIntValue(BluetoothGattCharacteristic.FORMAT_UINT16, 2);
                Log.i(TAG, "Power Data： power = " + power + " W");
                mCallbacks.onPowerReceived(power);
            }
        }
    };

    public BLEPowerSensorManager(final Context context) {
        mContext = context;
    }

    /**
     * Set data receive callback
     *
     * @param callbacks
     */
    public void setPowerCallbacks(final BLEPowerManagerCallbacks callbacks) {
        mCallbacks = callbacks;
    }

    /**
     * Connect BLE Power sensor connection
     *
     * @param context
     * @param device
     */
    public void connect(final Context context, final BluetoothDevice device) {
        mContext = context;

        if (mBtGattPower == null) {
            mBtGattPower = device.connectGatt(mContext, true, mGattCallback);
        } else {
            mBtGattPower.connect();
        }
    }

    /**
     * Disconnect BLE Power sensor connection
     */
    public void disconnect() {
        if (mBtGattPower != null) {
            mBtGattPower.disconnect();
        }
    }

    /**
     * Disconnect the bluetooth connection and release resources.
     */
    private void stopCSCConnection() {
        if (mBtGattPower != null) {
            mBtGattPower.close();
            mBtGattPower = null;
        }
    }
}
