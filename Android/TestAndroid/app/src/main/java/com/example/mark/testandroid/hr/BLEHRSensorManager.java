package com.example.mark.testandroid.hr;

/**
 * Created by Mark Chen on 15/05/2017.
 */

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.util.Log;

import com.example.mark.testandroid.common.BLESensorManager;
import com.example.mark.testandroid.common.BLESensorUtil;

import java.util.UUID;

public class BLEHRSensorManager extends BLESensorManager {
    private static final String TAG = "BLE-HR-Sensor";

    public static final String SERVICE_UUID_HR = "0000180D-0000-1000-8000-00805F9B34FB";
    private static final String CHARACTERISTIC_UUID_HR = "00002A37-0000-1000-8000-00805F9B34FB";

    private BluetoothGatt mBtGattHeartRate;
    private BLEHRManagerCallbacks mCallbacks;
    private BluetoothGattCharacteristic mCharacteristicHR;

    private final BluetoothGattCallback mGattCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            super.onConnectionStateChange(gatt, status, newState);
            Log.i(TAG, "HR Connection Status : " + status + ", New state : " + newState);

            if (newState == BluetoothProfile.STATE_CONNECTED) {
                mBtGattHeartRate.discoverServices();
                mCallbacks.onDeviceConnected();
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                // Disconnect
                mCallbacks.onDeviceDisconnected();
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            super.onServicesDiscovered(gatt, status);

            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.i(TAG, "HR Service Discovered - Success， status = " + status);
                for (BluetoothGattService service : mBtGattHeartRate.getServices()) {
                    Log.w(TAG, "Service UUID : " + service.getUuid().toString().toUpperCase());
                }

                // 心率
                BluetoothGattService serviceHR = mBtGattHeartRate.getService(UUID.fromString(SERVICE_UUID_HR));
                if (null != serviceHR) {
                    for (BluetoothGattCharacteristic characteristic : serviceHR.getCharacteristics()) {
                        Log.w(TAG, "#### HR Sensor - Characteristic UUID : " + characteristic.getUuid().toString().toUpperCase());
                    }

                    mCharacteristicHR = serviceHR.getCharacteristic(UUID.fromString(CHARACTERISTIC_UUID_HR));
                    if (null != mCharacteristicHR) {
                        mBtGattHeartRate.setCharacteristicNotification(mCharacteristicHR, true);
                        BluetoothGattDescriptor firstDesc = mCharacteristicHR.getDescriptor(BLESensorUtil.CLIENT_CHARACTERISTIC_CONFIG_DESCRIPTOR_UUID);
                        firstDesc.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        mBtGattHeartRate.writeDescriptor(firstDesc);
                    }
                }
            } else {
                Log.w(TAG, "onServicesDiscovered, status : " + status);
            }
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            super.onCharacteristicChanged(gatt, characteristic);

            if (characteristic.getUuid().toString().equalsIgnoreCase(CHARACTERISTIC_UUID_HR)) {
                byte[] data = characteristic.getValue();
                // 打印读取出来的值
//                final StringBuilder stringBuilder = new StringBuilder(data.length);
//                for(byte byteChar : data) {
//                    stringBuilder.append(String.format("%02X ", byteChar));
//                }
//                Log.w(TAG, "HR Data： " + stringBuilder.toString().toUpperCase());

                // 读取心率
                int format = -1;
                int flag = characteristic.getProperties();
                if ((flag & 0x01) != 0) {
                    format = BluetoothGattCharacteristic.FORMAT_UINT16;
                } else {
                    format = BluetoothGattCharacteristic.FORMAT_UINT8;
                }
                final int heartRate = characteristic.getIntValue(format, 1);
                Log.i(TAG, "HR Data： heartRate = " + heartRate + " BPM");
                mCallbacks.onHeartRateValueReceived(heartRate);
            }
        }
    };

    public BLEHRSensorManager(final Context context) {
        mContext = context;
    }

    /**
     * Set data receive callback
     *
     * @param callbacks
     */
    public void setHRCallbacks(final BLEHRManagerCallbacks callbacks) {
        mCallbacks = callbacks;
    }

    /**
     * Connect ble sensor
     *
     * @param context
     * @param device
     */
    public void connect(final Context context, final BluetoothDevice device) {
        mContext = context;

        if (mBtGattHeartRate == null) {
            mBtGattHeartRate = device.connectGatt(mContext, true, mGattCallback);
        } else {
            mBtGattHeartRate.connect();
        }
    }

    /**
     * Disconnect BLE sensor connection
     */
    public void disconnect() {
        if (mBtGattHeartRate != null) {
            mBtGattHeartRate.disconnect();
        }
    }

    /**
     * Disconnect the bluetooth connection and release resources.
     */
    private void stopCSCConnection() {
        if (mBtGattHeartRate != null) {
            mBtGattHeartRate.close();
            mBtGattHeartRate = null;
        }
    }
}
