//
//  SelectListTableViewController.m
//  BleSensorConnector
//
//  Created by Mark on 2018/1/25.
//  Copyright © 2018年 MarkCJ. All rights reserved.
//

#import "SelectListTableViewController.h"

#import "SensorViewController.h"

@interface SelectListTableViewController ()

@property (nonatomic, strong) NSArray *arrDataSource;

@end

@implementation SelectListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Ble Toolbox";
    
    [self setUpData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data and UI setup
- (void)setUpData {
    if (self.arrDataSource == nil) {
        // Every Element is a array, format as below:
        self.arrDataSource = @[
                               @[@"Sensor", @"Including Heart Rate, Power, Speed, Cadence and etc"],
                               @[@"Beacon", @"Searching and sign"]
                               ];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ble_select_tableview_cell_reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    NSArray *arrElement = self.arrDataSource[indexPath.row];
    cell.textLabel.text = arrElement[0];
    cell.detailTextLabel.text = arrElement[1];
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *controller = nil;
    
    switch (indexPath.row) {
        case 0:     // Sensor
        {
            controller = [[SensorViewController alloc] init];
        }
            break;
            
        case 1:     // Beacon
        {
        }
            break;
            
        default:
            break;
    }
    
    // Push the view controller.
    [self.navigationController pushViewController:controller animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
