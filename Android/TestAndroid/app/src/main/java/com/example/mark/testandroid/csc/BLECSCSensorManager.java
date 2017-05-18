package com.example.mark.testandroid.csc;

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

/**
 * Created by Mark Chen on 17/05/2017.
 */

public class BLECSCSensorManager extends BLESensorManager {
    private static final String TAG = "BLE-CSC-Sensor";
    public static final String SERVICE_UUID_CYCLING_SPEED_AND_CADENCE = "00001816-0000-1000-8000-00805F9B34FB";
    private static final String CHARACTERISTIC_UUID_CSC_MEASUREMENT = "00002A5B-0000-1000-8000-00805F9B34FB";

    private BLECSCSensorManagerCallbacks mCallbacks;
    private BluetoothGatt mBtGattCSC;

    private final BluetoothGattCallback mGattCallback = new BluetoothGattCallback() {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            super.onConnectionStateChange(gatt, status, newState);
            Log.i("mark", "[CSC] Connection Status[0-Disconnected, 1-Connecting, 2-Connected]: " + status + ", New state : " + newState);

            if (newState == BluetoothProfile.STATE_CONNECTED) {
                mBtGattCSC.discoverServices();
                mCallbacks.onDeviceConnected();
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                // Disconnect
                mCallbacks.onDeviceDisconnected();
                stopCSCConnection();
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            super.onServicesDiscovered(gatt, status);

            if (status == BluetoothGatt.GATT_SUCCESS) {
                // CSC, aka. Cycling Speed and Cadence
                BluetoothGattService serviceSpeedAndCadence = mBtGattCSC.getService(UUID.fromString(SERVICE_UUID_CYCLING_SPEED_AND_CADENCE));
                if (null != serviceSpeedAndCadence) {
                    for (BluetoothGattCharacteristic characteristic : serviceSpeedAndCadence.getCharacteristics()) {
                        Log.w(TAG, "#### CSC Sensor - Characteristic UUID : " + characteristic.getUuid().toString().toUpperCase());
                    }

                    BluetoothGattCharacteristic characteristicCSC = serviceSpeedAndCadence.getCharacteristic(UUID.fromString(CHARACTERISTIC_UUID_CSC_MEASUREMENT));
                    if (characteristicCSC != null) {
                        mBtGattCSC.setCharacteristicNotification(characteristicCSC, true);
                        BluetoothGattDescriptor firstDesc = characteristicCSC.getDescriptor(BLESensorUtil.CLIENT_CHARACTERISTIC_CONFIG_DESCRIPTOR_UUID);
                        firstDesc.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                        mBtGattCSC.writeDescriptor(firstDesc);
                    }
                }
            } else {
                Log.w(TAG, "onServicesDiscovered, status : " + status);
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

            if (characteristic.getUuid().toString().equalsIgnoreCase(CHARACTERISTIC_UUID_CSC_MEASUREMENT)) {
                // Read and calculate speed and cadence value
                int offset = 0;
                final int flag = characteristic.getValue()[offset];
                offset += 1;

                // Wheel Revolution Data Present, index 0, size 1 bit, 0 False, 1 True
                final boolean wheelRevPresent = (flag & 0x01) > 0;

                // Field exists if the key of bit 0 of the Flags field is set to 1
                int wheelRevolutions = 0;       // wheel revolutions count
                // Unit has a resolution of 1/1024s.
                // C1: Field exists if the key of bit 0 of the Flags field is set to 1.
                int lastWheelEventTime = 0;     // wheel data last capture time
                if (wheelRevPresent) {
                    wheelRevolutions = characteristic.getIntValue(BluetoothGattCharacteristic.FORMAT_UINT32, offset);
                    offset += 4;

                    lastWheelEventTime = characteristic.getIntValue(BluetoothGattCharacteristic.FORMAT_UINT16, offset);
                    offset += 2;
                }

                // Crank Revolution Data Present, index 1, size 1 bit, 0 False, 1 True.
                final boolean crankRevPresent = (flag & 0x02) > 0;
                int crankRevolutions = 0;   // Crank revolution count
                int lastCrankEventTime = 0;
                if (crankRevPresent) {
                    crankRevolutions = characteristic.getIntValue(BluetoothGattCharacteristic.FORMAT_UINT16, offset);
                    offset += 2;

                    lastCrankEventTime = characteristic.getIntValue(BluetoothGattCharacteristic.FORMAT_UINT16, offset);
                }
                mCallbacks.onSpeedMeasurementReceived(wheelRevolutions, lastWheelEventTime);
                mCallbacks.onCadenceMeasurementReceived(wheelRevolutions, lastCrankEventTime);
            }
        }
    };

    public BLECSCSensorManager(final Context context) {
        mContext = context;
    }

    /**
     * Set data receive callback
     *
     * @param callbacks
     */
    public void setCSCCallbacks(final BLECSCSensorManagerCallbacks callbacks) {
        mCallbacks = callbacks;
    }

    /**
     * Connect BLE CSC sensor connection
     *
     * @param context
     * @param device
     */
    public void connect(final Context context, final BluetoothDevice device) {
        mContext = context;

        if (mBtGattCSC == null) {
            mBtGattCSC = device.connectGatt(mContext, true, mGattCallback);
        } else {
            mBtGattCSC.connect();
        }
    }

    /**
     * Disconnect BLE CSC sensor connection
     */
    public void disconnect() {
        if (mBtGattCSC != null) {
            mBtGattCSC.disconnect();
        }
    }

    /**
     * Disconnect the bluetooth connection and release resources.
     */
    private void stopCSCConnection() {
        if (mBtGattCSC != null) {
            mBtGattCSC.close();
            mBtGattCSC = null;
        }
    }
}
