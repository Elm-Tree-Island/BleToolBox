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
@property (nonatomic, strong) UILabel *lblHR;
@property (nonatomic, strong) UILabel *lblCadence;
@property (nonatomic, strong) UILabel *lblSpeed;

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
    self.lblPower.text = @"Power: ";
    [self.view addSubview:self.lblPower];
    
    // 心率
    self.lblHR = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 200, 40)];
    self.lblHR.textColor = [UIColor whiteColor];
    self.lblHR.text = @"HR: ";
    [self.view addSubview:self.lblHR];
    
    // 速度
    self.lblSpeed = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 200, 40)];
    self.lblSpeed.textColor = [UIColor whiteColor];
    self.lblSpeed.text = @"Speed: ";
    [self.view addSubview:self.lblSpeed];
    
    // 速度
    self.lblCadence = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, 200, 40)];
    self.lblCadence.textColor = [UIColor whiteColor];
    self.lblCadence.text = @"Cadence: ";
    [self.view addSubview:self.lblCadence];
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
    NSString *logContent = [NSString stringWithFormat:@"HR : %d BPM", hr];
    NSLog(@"%@", logContent);
    self.lblHR.text = logContent;
}

#pragma mark - BLEPowerSensorPeripheralDelegate
- (void) didPowerDataReceived:(int)powerInWatts {
    NSString *logContent = [NSString stringWithFormat:@"Power : %d watts", powerInWatts];
    NSLog(@"%@", logContent);
    self.lblPower.text = logContent;
}

#pragma mark - BLECSCSensorPeripheralDelegate
- (void) didSpeedWheelRevolution:(int)wheelRevolution lastWheelEventTime:(int)lastEventTime {
    double speed = [BleSensorConnectorUtil calculateSpeedWithWheelRev:wheelRevolution lastWheelEventTime:lastEventTime wheelCircumferenceInMM:2046];
    NSString *logContent = [NSString stringWithFormat:@"Speed : %.1f km/h", speed];
    NSLog(@"%@", logContent);
    self.lblSpeed.text = logContent;
}

- (void) didCadenceRevolution:(int)cadenceRev lastCadenceEventTime:(int)lastEventTime {
    int cadence = [BleSensorConnectorUtil calculateCadenceWithCrankRev:cadenceRev lastCrankEventTime:lastEventTime];
    NSString *logContent = [NSString stringWithFormat:@"Cadence : %d RPM", cadence];
    NSLog(@"%@", logContent);
    self.lblCadence.text = logContent;
}

@end
