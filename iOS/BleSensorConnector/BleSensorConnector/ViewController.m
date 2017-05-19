//
//  ViewController.m
//  BleSensorConnector
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#import "ViewController.h"
#import "BLESensorCentralManager.h"
#import "BleSensorConnectorUtil.h"

@interface ViewController () <BLEHRSensorPeripheralDelegate, BLEPowerSensorPeripheralDelegate, BLECSCSensorPeripheralDelegate>

@property (nonatomic, strong) UILabel *lblPower;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sensor Connector";
    
    // 开始蓝牙扫描
    [[BLESensorCentralManager defaultManager] scan];
    [BLESensorCentralManager defaultManager].powerDelegate = self;
    [BLESensorCentralManager defaultManager].cscDelegate = self;
    [BLESensorCentralManager defaultManager].hrDelegate = self;
    
    // 功率
    self.lblPower = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 200, 40)];
    self.lblPower.textColor = [UIColor whiteColor];
    [self.view addSubview:self.lblPower];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[BLESensorCentralManager defaultManager] disconnect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BLEHRSensorPeripheralDelegate Method
- (void) didHRDataReceived:(int) hr {
    NSLog(@"HR : %d BPM", hr);
}

#pragma mark - BLEPowerSensorPeripheralDelegate
- (void) didPowerDataReceived:(int)powerInWatts {
    NSLog(@"Power : %d watts", powerInWatts);
}

#pragma mark - BLECSCSensorPeripheralDelegate
- (void) didSpeedWheelRevolution:(int)wheelRevolution lastWheelEventTime:(int)lastEventTime {
    double speed = [BleSensorConnectorUtil calculateSpeedWithWheelRev:wheelRevolution lastWheelEventTime:lastEventTime wheelCircumferenceInMM:2046];
    NSLog(@"Speed : %.1f km/h", speed);
}

- (void) didCadenceRevolution:(int)cadenceRev lastCadenceEventTime:(int)lastEventTime {
    int cadence = [BleSensorConnectorUtil calculateCadenceWithCrankRev:cadenceRev lastCrankEventTime:lastEventTime];
    NSLog(@"Cadence : %d RPM", cadence);
}

@end
