//
//  ViewController.m
//  BleToolBox
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#import "SensorViewController.h"
#import "BLESensorCentralManager.h"
#import "BleSensorConnectorUtil.h"

@interface SensorViewController () <BLEHRSensorPeripheralDelegate, BLEPowerSensorPeripheralDelegate, BLECSCSensorPeripheralDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblPowerValue;
@property (weak, nonatomic) IBOutlet UILabel *lblHRValue;
@property (weak, nonatomic) IBOutlet UILabel *lblCadenceValue;
@property (weak, nonatomic) IBOutlet UILabel *lblSpeedValue;

@end

@implementation SensorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sensor";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 开始蓝牙扫描
    [[BLESensorCentralManager defaultManager] startScan];
    [BLESensorCentralManager defaultManager].powerDelegate = self;
    [BLESensorCentralManager defaultManager].cscDelegate = self;
    [BLESensorCentralManager defaultManager].hrDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop scan and disconnect.
    [[BLESensorCentralManager defaultManager] stopScan];
    [[BLESensorCentralManager defaultManager] disconnect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%@ dealloc method called", self.class);
}

#pragma mark - BLEHRSensorPeripheralDelegate Method
- (void) didHRDataReceived:(int) hr {
    NSString *logContent = [NSString stringWithFormat:@"%d BPM", hr];
    NSLog(@"%@", logContent);
    self.lblHRValue.text = logContent;
}

#pragma mark - BLEPowerSensorPeripheralDelegate
- (void) didPowerDataReceived:(int)powerInWatts {
    NSString *logContent = [NSString stringWithFormat:@"%d W", powerInWatts];
    NSLog(@"%@", logContent);
    self.lblPowerValue.text = logContent;
}

#pragma mark - BLECSCSensorPeripheralDelegate
- (void) didSpeedWheelRevolution:(int)wheelRevolution lastWheelEventTime:(int)lastEventTime {
    double speed = [BleSensorConnectorUtil calculateSpeedWithWheelRev:wheelRevolution lastWheelEventTime:lastEventTime wheelCircumferenceInMM:2046];
    NSString *logContent = [NSString stringWithFormat:@"%.1f km/h", speed];
    NSLog(@"%@", logContent);
    self.lblSpeedValue.text = logContent;
}

- (void) didCadenceRevolution:(int)cadenceRev lastCadenceEventTime:(int)lastEventTime {
    int cadence = [BleSensorConnectorUtil calculateCadenceWithCrankRev:cadenceRev lastCrankEventTime:lastEventTime];
    NSString *logContent = [NSString stringWithFormat:@"%d RPM", cadence];
    NSLog(@"%@", logContent);
    self.lblCadenceValue.text = logContent;
}

@end
