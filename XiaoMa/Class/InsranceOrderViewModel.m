//
//  InsranceOrderViewModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsranceOrderViewModel.h"
#import "XiaoMa.h"
#import "GetInsuranceOrderListOp.h"
#import "InsuranceOrderDetailVC.h"

@implementation InsranceOrderViewModel

- (void)reloadData
{
    @weakify(self);
    GetInsuranceOrderListOp *op = [GetInsuranceOrderListOp new];
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"Loading..."];
    }] subscribeNext:^(GetInsuranceOrderListOp *rspOp) {
        @strongify(self);
        [gToast dismiss];
        self.orders = rspOp.rsp_orders;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate and UITableViewDatasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InsuranceOrderDetailVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderDetailVC" inStoryboard:@"Mine"];
    vc.order = [self.orders safetyObjectAtIndex:indexPath.section];
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.orders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *cell = (JTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InsuranceCell" forIndexPath:indexPath];
    UILabel *nameL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *stateL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *contentL = (UILabel *)[cell.contentView viewWithTag:2001];
    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:3002];
    UILabel *paymentL = (UILabel *)[cell.contentView viewWithTag:3003];
    UIButton *bottomB = (UIButton *)[cell.contentView viewWithTag:4001];
    
    HKInsuranceOrder *order = [self.orders safetyObjectAtIndex:indexPath.section];
    
    nameL.text = [order descForCurrentInstype];
    stateL.text = [order descForCurrentStatus];
    contentL.text = [order generateContent];
    timeL.text = [order.lstupdatetime dateFormatForYYYYMMddHHmm];
    priceL.text = [NSString stringWithFormat:@"￥%d", (int)(order.policy.premium)];
    paymentL.text = [order paymentForCurrentChannel];

    cell.separatorInset = UIEdgeInsetsZero;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
}

@end
