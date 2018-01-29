//
//  BeaconViewController.m
//  BleToolBox
//
//  Created by Mark on 2018/1/25.
//  Copyright © 2018年 MarkCJ. All rights reserved.
//

#import "BeaconViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

// Beacon sign in data saving.
#import "BleBeaconSigninModel.h"

#define TARGET_BEACON_DEVICE_UUID           @"E06AFC0F-F8AE-4EA9-9095-1BF68DB6494D"
#define TARGET_BEACON_SERVICE_UUID          @"00001803-494C-4F47-4943-544543480000"

@interface BeaconViewController () <CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *lblUUIDValue;
@property (weak, nonatomic) IBOutlet UILabel *lblNameValue;
@property (weak, nonatomic) IBOutlet UILabel *lblRSSIValue;
@property (weak, nonatomic) IBOutlet UILabel *lblAdvIntervalValue;
@property (weak, nonatomic) IBOutlet UITableView *tableviewSignResult;

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, assign) NSTimeInterval prevAdvTimeInterval;

@property (nonatomic, strong) RLMRealm *realmInstance;      // 数据库存储Instance
@property (nonatomic, strong) NSDate *lastSignInTime;       // 上次签到时间

@property (nonatomic, strong) RLMResults<BleBeaconSignInModel *> *resultsAllSignInRecords;         // 所有的签到记录数据源

@end

@implementation BeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Beacon";
    
    // Scan device in the main thread
    if (self.centralManager == nil) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:[NSDictionary dictionaryWithObject:@YES forKey:CBCentralManagerOptionShowPowerAlertKey]];
    }
    
    [self setupTableView];
    
    if (self.realmInstance == nil) {
        self.realmInstance = [RLMRealm defaultRealm];
        
        // Get all the sign in records
        self.resultsAllSignInRecords = [[BleBeaconSignInModel allObjects] sortedResultsUsingKeyPath:@"signInTime" ascending:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableviewSignResult reloadData];
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

#pragma mark - UI Setup
- (void)setupTableView {
    self.tableviewSignResult.delegate = self;
    self.tableviewSignResult.dataSource = self;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Current Bluetooth State = %ld (5 -> ON)", (long)central.state);
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TARGET_BEACON_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
        //        [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
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
    
    // Service UUID Value
    CBUUID *advDataServiceUUID = arrServices[0];
    
    if (localName != nil && advDataServiceUUID && [advDataServiceUUID.UUIDString isEqualToString:TARGET_BEACON_SERVICE_UUID]) {
        self.lblNameValue.text = localName;
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
        
        
        // 获取最近的签到时间
        BleBeaconSignInModel *signInModel = [self getLatestSignInRecord:TARGET_BEACON_SERVICE_UUID];
        if (signInModel == nil || (signInModel && [self canSignNow:signInModel.signInTime])) {
            // 保存打点到数据库
            BleBeaconSignInModel *signInModel = [[BleBeaconSignInModel alloc] initWithBeaconName:localName UUID:advDataServiceUUID.UUIDString RSSI:RSSI.integerValue signInTime:[NSDate date]];
            
            // 保存到数据库
            [self.realmInstance beginWriteTransaction];
            [self.realmInstance addObject:signInModel];
            [self.realmInstance commitWriteTransaction];
            NSLog(@"签到成功, 签到信息为：%@", signInModel);
            
            // 刷新UI
            self.resultsAllSignInRecords = [[BleBeaconSignInModel allObjects] sortedResultsUsingKeyPath:@"signInTime" ascending:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewSignResult reloadData];
            });
        } else {
            NSLog(@"今日已签到，无需重复签到");
        }
        
        // 签到完成后停止扫描
        [self.centralManager stopScan];
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

#pragma mark - DB Method

/**
 获取最新的签到记录
 
 @return BleBeaconSignInModel
 */
- (BleBeaconSignInModel *)getLatestSignInRecord:(NSString *)serviceUUID {
    if (serviceUUID == nil || serviceUUID.length == 0) {
        return nil;
    }
    
    BleBeaconSignInModel *latestSignInRecord = nil;
    RLMResults<BleBeaconSignInModel *> *allRecords = [BleBeaconSignInModel objectsWhere:@"beaconUUID == %@", serviceUUID];
    
    if (allRecords && allRecords.count > 0) {
        RLMResults<BleBeaconSignInModel *> *sortedAllRecords = [allRecords sortedResultsUsingKeyPath:@"signInTime" ascending:NO];
        latestSignInRecord = [sortedAllRecords objectAtIndex:0];
    }
    
    return  latestSignInRecord;
}

/**
 Clear all the data in the database
 
 @return BOOL, delete data result.
 */
- (BOOL)deleteAllDataInDB {
    if (self.realmInstance) {
        // Test, delete all the data in the DB
        [self.realmInstance beginWriteTransaction];
        [self.realmInstance deleteAllObjects];
        [self.realmInstance commitWriteTransaction];
        return YES;
    } else {
        return NO;
    }
}

/**
 检查是否可以签到，即检测是不是同一天
 
 @return BOOL
 */
- (BOOL)canSignNow:(NSDate *)lastSignInTime {
    if (lastSignInTime == nil) {
        return NO;
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:lastSignInTime];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsAllSignInRecords.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"beacon_sign_in_tableview_cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    BleBeaconSignInModel *record = [self.resultsAllSignInRecords objectAtIndex:indexPath.row];
    cell.textLabel.text = record.beaconName;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd hh:mm:ss";
    cell.detailTextLabel.text = [dateFormatter stringFromDate:record.signInTime];
    
    return cell;
}

@end
