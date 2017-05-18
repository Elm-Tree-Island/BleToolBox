package com.example.mark.testandroid;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.ParcelUuid;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import com.example.mark.testandroid.common.BLESensorUtil;
import com.example.mark.testandroid.common.BLECSCUtil;
import com.example.mark.testandroid.csc.BLECSCSensorManager;
import com.example.mark.testandroid.csc.BLECSCSensorManagerCallbacks;
import com.example.mark.testandroid.hr.BLEHRManagerCallbacks;
import com.example.mark.testandroid.hr.BLEHRSensorManager;
import com.example.mark.testandroid.power.BLEPowerManagerCallbacks;
import com.example.mark.testandroid.power.BLEPowerSensorManager;

import java.util.ArrayList;
import java.util.List;

/**
 *
 */
public class MainActivity extends AppCompatActivity implements BLECSCSensorManagerCallbacks, BLEPowerManagerCallbacks, BLEHRManagerCallbacks {
    private static final String TAG = "BLE-Sensor";

    private BluetoothAdapter mBTAdapter;
    private BluetoothLeScanner mBTScanner;

    private BLECSCSensorManager mCscManager;
    private BLEHRSensorManager mHRManager;
    private BLEPowerSensorManager mPowerManager;

    private ScanCallback mScanCallback = new ScanCallback() {

        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            super.onScanResult(callbackType, result);

            final BluetoothDevice device = result.getDevice();
            String name = device.getName();
            Log.w(TAG, "### Scan ble sensor found : " + name);

            List<ParcelUuid> serviceUuidList = result.getScanRecord().getServiceUuids();
            if (serviceUuidList.contains(ParcelUuid.fromString(BLECSCSensorManager.SERVICE_UUID_CYCLING_SPEED_AND_CADENCE))) {
                mCscManager.connect(getApplicationContext(), device);
            } else if (serviceUuidList.contains(ParcelUuid.fromString(BLEHRSensorManager.SERVICE_UUID_HR))) {
                mHRManager.connect(getApplicationContext(), device);
            } else if (serviceUuidList.contains(ParcelUuid.fromString(BLEPowerSensorManager.SERVICE_UUID_CYCLING_POWER))) {
                mPowerManager.connect(getApplicationContext(), device);
            }
        }

        @Override
        public void onScanFailed(int errorCode) {
            Log.e(TAG, String.format("### onScanFailed, errorCode %d", errorCode));
        }
    };

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Init the bluetooth module, including scanner and bleGatt
        initBluetooth();
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (mBTAdapter.isEnabled()) {
            mBTScanner = mBTAdapter.getBluetoothLeScanner();
            scanLeDevice(true);
        }
    }

    @Override
    protected void onDestroy () {
        super.onDestroy();

        // Stop scan ble sensor
        scanLeDevice(false);

        mHRManager.disconnect();
        mCscManager.disconnect();
        mPowerManager.disconnect();
    }

    /*
     * Init the bluetooth module, including scanner and bleGatt
     */
    private void initBluetooth() {
        final BluetoothManager btManager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        mBTAdapter = btManager.getAdapter();

        if (mBTAdapter == null || !mBTAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, BLESensorUtil.REQUEST_ENABLE_BT);
        }

        mCscManager = new BLECSCSensorManager(this);
        mCscManager.setCSCCallbacks(this);

        mPowerManager = new BLEPowerSensorManager(this);
        mPowerManager.setPowerCallbacks(this);

        mHRManager = new BLEHRSensorManager(this);
        mHRManager.setHRCallbacks(this);
    }

    /**
     * Start scan ble sensor, now, including HR, CSC, Power
     * @param enable
     */
    private void scanLeDevice(final boolean enable) {
        if (enable) {
            int apiVersion = android.os.Build.VERSION.SDK_INT;
            if (apiVersion > Build.VERSION_CODES.KITKAT) {
                Log.w(TAG, "!!! [High Android Version] Start Scan !!!");

                List<ScanFilter> scanList = new ArrayList<>();
                ScanFilter hrFilter = new ScanFilter.Builder()
                        .setServiceUuid(ParcelUuid.fromString(BLEHRSensorManager.SERVICE_UUID_HR))
                        .build();
                ScanFilter speedAndCadenceFilter = new ScanFilter.Builder()
                        .setServiceUuid(ParcelUuid.fromString(BLECSCSensorManager.SERVICE_UUID_CYCLING_SPEED_AND_CADENCE))
                        .build();
                ScanFilter powerFilter = new ScanFilter.Builder()
                        .setServiceUuid(ParcelUuid.fromString(BLEPowerSensorManager.SERVICE_UUID_CYCLING_POWER))
                        .build();
                scanList.add(hrFilter);
                scanList.add(speedAndCadenceFilter);
                scanList.add(powerFilter);
                ScanSettings settings = new ScanSettings.Builder()
                        .setCallbackType(ScanSettings.CALLBACK_TYPE_ALL_MATCHES)
                        .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                        .build();
                mBTScanner.startScan(scanList, settings, mScanCallback);
            } else {
                mBTAdapter.startLeScan(new BluetoothAdapter.LeScanCallback() {

                    @Override
                    public void onLeScan(BluetoothDevice device, int rssi, byte[] scanRecord) {
                        Log.w(TAG, "!!! [Lower Version] Start Scan !!!");
                    }
                });
            }
        } else {
            Log.w(TAG, "!!! Stop Scan !!!");
            mBTScanner.stopScan(mScanCallback);
            mBTScanner = null;
        }
    }

    @Override
    public void onSpeedMeasurementReceived(int wheelRevolutions, int wheelCrankEventTime) {
        double speedInKMPH = BLECSCUtil.calculateSpeed(wheelRevolutions, wheelCrankEventTime, 2096) * 3.6;
        if (speedInKMPH != 0) {
            Log.i(TAG,  "Speed Data：wheelRevolutions = " + wheelRevolutions + ", lastWheelEventTime = " + wheelCrankEventTime
                    + ", Speed = " + speedInKMPH + " km/h");
        }
    }

    @Override
    public void onCadenceMeasurementReceived(int crankRevolutions, int lastCrankEventTime) {
        double cadence = BLECSCUtil.calculateCadence(crankRevolutions, lastCrankEventTime);
        if(cadence != 0) {
            Log.i(TAG, "Cadence Data：crankRevolutions = " +  crankRevolutions
                    + ", lastCrankEventTime = " + lastCrankEventTime
                    + ", Cadence = " + cadence);
        }
    }

    @Override
    public void onDeviceConnected() {
        Log.w(TAG, "设备连接建立");
    }

    @Override
    public void onDeviceDisconnected() {
        Log.w(TAG, "设备连接断开");
    }

    @Override
    public void onBondingRequired() {
        Log.w(TAG, "绑定请求确认");
    }

    @Override
    public void onBonded() {
        Log.w(TAG, "绑定成功");
    }

    @Override
    public void onError(String message, int errorCode) {
        Log.w(TAG, "[Error] 出错， Msg: " + message);
    }

    @Override
    public void onHeartRateValueReceived(int hrValue) {
        Log.w(TAG, "收到心率值：" + hrValue);
    }

    @Override
    public void onPowerReceived(int power) {
        Log.w(TAG, "收到功率值： " + power);
    }
}