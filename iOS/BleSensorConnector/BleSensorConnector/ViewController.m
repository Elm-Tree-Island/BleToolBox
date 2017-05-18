//
//  ViewController.m
//  BleSensorConnector
//
//  Created by Mark C.J. on 18/05/2017.
//  Copyright © 2017 MarkCJ. All rights reserved.
//

#import "ViewController.h"
#import "BLESensorCentralManager.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *lblPower;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sensor Connector";
    
    // 开始蓝牙扫描
    [[BLESensorCentralManager defaultManager] scan];
    
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


@end
