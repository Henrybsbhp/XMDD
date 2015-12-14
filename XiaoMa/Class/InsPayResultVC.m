//
//  InsPayResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/11.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsPayResultVC.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"

#import "InsSubmitResultVC.h"

@interface InsPayResultVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation InsPayResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Datasource
- (void)reloadData
{
    HKCellData *headerCell = [HKCellData dataWithCellID:@"Header" tag:nil];
    [headerCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 66;
    }];
    HKCellData *baseCell = [HKCellData dataWithCellID:@"Base" tag:nil];
    [baseCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 115;
    }];
    HKCellData *contactCell = [HKCellData dataWithCellID:@"Contact" tag:nil];
    [contactCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 88;
    }];
    HKCellData *addrCell = [HKCellData dataWithCellID:@"Address" tag:nil];
    [addrCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 105;
    }];
    
    self.datasource = @[headerCell, baseCell, contactCell, addrCell];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionSubmit:(id)sender
{
    InsSubmitResultVC *vc = [UIStoryboard vcWithId:@"InsSubmitResultVC" inStoryboard:@"Insurance"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Base" tag:nil]) {
        [self resetAddressCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Contact" tag:nil]) {
        [self resetContactCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Address" tag:nil]) {
        [self resetAddressCell:cell forData:data];
    }
    return cell;
}

- (void)resetBaseCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    UILabel *numberL = [cell viewWithTag:1004];
}

- (void)resetContactCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    HKSubscriptInputField *nameF = [cell viewWithTag:1001];
    HKSubscriptInputField *phoneF = [cell viewWithTag:1002];
}

- (void)resetAddressCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *textL = [cell viewWithTag:10011];
    UIButton *selectB = [cell viewWithTag:10012];
    HKSubscriptInputField *addrF = [cell viewWithTag:1002];
}

@end
