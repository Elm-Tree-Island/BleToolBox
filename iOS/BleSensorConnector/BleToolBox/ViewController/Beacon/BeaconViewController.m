//
//  BeaconViewController.m
//  BleToolBox
//
//  Created by Mark on 2018/1/25.
//  Copyright © 2018年 MarkCJ. All rights reserved.
//

#import "BeaconViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface BeaconViewController () <CBCentralManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblUUIDValue;
@property (weak, nonatomic) IBOutlet UILabel *lblNameValue;
@property (weak, nonatomic) IBOutlet UILabel *lblRSSIValue;
@property (weak, nonatomic) IBOutlet UILabel *lblAdvIntervalValue;

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, assign) NSTimeInterval prevAdvTimeInterval;

@end

@implementation BeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Beacon";
    
    // Scan device in the main thread
    if (self.centralManager == nil) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:@YES forKey:CBCentralManagerOptionShowPowerAlertKey]];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.centralManager) {
        [self.centralManager stopScan];
        self.centralManager = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Current Bluetooth State = %ld (5 -> ON)", (long)central.state);
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/advertisement_data_retrieval_keys?language=objc
    // Advertisement Data Retrieval Keys:
    //    CBAdvertisementDataLocalNameKey
    //    CBAdvertisementDataManufacturerDataKey
    //    CBAdvertisementDataServiceDataKey
    //    CBAdvertisementDataServiceUUIDsKey
    //    CBAdvertisementDataOverflowServiceUUIDsKey
    //    CBAdvertisementDataTxPowerLevelKey
    //    CBAdvertisementDataIsConnectable
    //    CBAdvertisementDataSolicitedServiceUUIDsKey
    
    // Device Name
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    // Manufacturer Data
    NSData *manuFacturerData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    
    // Service Data
    //    A dictionary containing service-specific advertisement data.
    //
    //    The keys are CBUUID objects, representing CBService UUIDs. The values are NSData objects, representing service-specific data.
    NSDictionary *dicServiceData = [advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
    
    // Service UUID, An array of service UUIDs.
    NSArray *arrServices = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    
    // An array of one or more CBUUID objects, representing CBService UUIDs that were found in the “overflow” area of the advertisement data.
    //    Due to the nature of the data stored in this area, UUIDs listed here are “best effort” and may not always be accurate. For details about the overflow area of advertisement data, see the startAdvertising: method in CBPeripheralManager.
    NSArray *arrOverflowServiceUUIDs = [advertisementData objectForKey:CBAdvertisementDataOverflowServiceUUIDsKey];
    
    //    A number (an instance of NSNumber) containing the transmit power of a peripheral.
    //
    //    This key and value are available if the broadcaster (peripheral) provides its Tx power level in its advertising packet. Using the RSSI value and the Tx power level, it is possible to calculate path loss.
    NSNumber *txPowerLevel = [advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey];
    
    //    A Boolean value that indicates whether the advertising event type is connectable.
    //
    //    The value for this key is an NSNumber object. You can use this value to determine whether a peripheral is connectable at a particular moment.
    BOOL isConnectable = [advertisementData objectForKey:CBAdvertisementDataIsConnectable];
    
    // An array of one or more CBUUID objects, representing CBService UUIDs.
    NSArray *arrSolicitedServiceUUIDs = [advertisementData objectForKey:CBAdvertisementDataSolicitedServiceUUIDsKey];
    
    if (localName != nil && localName.length > 0) {
        self.lblNameValue.text = localName;
        
        // Service UUID Value
        CBUUID *advDataServiceUUID = arrServices[0];
        self.lblUUIDValue.text = advDataServiceUUID.UUIDString;
        
        self.lblRSSIValue.text = [NSString stringWithFormat:@"%d dBm", RSSI.intValue];
        
        NSDate *date = [NSDate date];
        NSTimeInterval timeInterval = date.timeIntervalSince1970;
        int advTimeInterval = (timeInterval - self.prevAdvTimeInterval) * 1000;
        if (self.prevAdvTimeInterval != 0 && advTimeInterval != 0) {
            self.lblAdvIntervalValue.text = [NSString stringWithFormat:@"%d", advTimeInterval];
            NSLog(@"FOUNT Device %@, adv interval = %d ms", localName, advTimeInterval);
        }
        self.prevAdvTimeInterval = timeInterval;
        
    }
}

/**
 Called when peripheral connected.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"BLE - CONNECTED TO : %@", peripheral.name);
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    if (error) {
        NSLog(@"[ERROR] CONNECT DEVICE FAILED， error = %@", error.localizedDescription);
    }
}

/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection
 *                      was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been
 *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
 *
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    if (error == nil) {
        // Clean resource
    } else {
        NSLog(@"Fail Disconnect");
    }
}

@end
