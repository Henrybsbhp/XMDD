//
//  InsInputDateVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/6.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "InsInputDateVC.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"

@interface InsInputDateVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;

@end

@implementation InsInputDateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Datasource
- (void)reloadData
{
    HKCellData *cell1 = [HKCellData dataWithCellID:@"Input" tag:@0];
    cell1.customInfo[@"title"] = @"商业险启保日";
    cell1.customInfo[@"placehold"] = @"请输入商业险日期";
    
    HKCellData *cell2 = [HKCellData dataWithCellID:@"Input" tag:@1];
    cell2.customInfo[@"title"] = @"交强险启保日";
    cell2.customInfo[@"]
    
    self.datasource = @[cell1, cell2];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionNext:(id)sender
{
    
}

#pragma mark - UITableViewDelegate and datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    [self resetInputCell:cell data:data];
    
    return cell;
}

- (void)resetInputCell:(UITableViewCell *)cell data:(HKCellData *)data
{
    UILabel *titleL = [cell viewWithTag:10011];
    HKSubscriptInputField *inputF = [cell viewWithTag:10012];
    
    titleL.text = data.customInfo[@"title"];
    inputF
}

@end
