//
//  CarwashOrderViewModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarwashOrderViewModel.h"
#import "XiaoMa.h"
#import "GetCarwashOrderListOp.h"
#import "CarwashOrderDetailVC.h"

@implementation CarwashOrderViewModel

- (void)reloadData
{
    @weakify(self);
    GetCarwashOrderListOp *op = [GetCarwashOrderListOp new];
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"Loading..."];
    }] subscribeNext:^(GetCarwashOrderListOp *rspOp) {
        @strongify(self);
        [gToast dismiss];
        self.orders = rspOp.rsp_orders;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate and UITableViewDatasource

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
    JTTableViewCell *cell = (JTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CarwashCell" forIndexPath:indexPath];
    UILabel *nameL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *stateL = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:2001];
    UILabel *serviceL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:2003];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:3002];
    UILabel *paymentL = (UILabel *)[cell.contentView viewWithTag:3003];
    UIButton *bottomB = (UIButton *)[cell.contentView viewWithTag:4001];
    
    HKServiceOrder *order = [self.orders safetyObjectAtIndex:indexPath.section];
    
    nameL.text = order.shop.shopName;
    stateL.text = @"交易成功";
    [[[gAppMgr.mediaMgr rac_getPictureForUrl:[order.shop.picArray safetyObjectAtIndex:0]  withDefaultPic:@"cm_shop"]
      takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        iconV.image = x;
    }];
    JTShopService *service = [order currentService];
    serviceL.text = service.serviceName;
    timeL.text = [order.txtime dateFormatForYYYYMMddHHmm];
    priceL.text = [NSString stringWithFormat:@"￥%d", (int)(service.contractprice)];
    paymentL.text = [order paymentForCurrentChannel];
    [bottomB setTitle:order.ratetime ? @"已评价" : @"去评价" forState:UIControlStateNormal];
    bottomB.enabled = (BOOL)order.ratetime;
    [[[bottomB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
    }];
    
    
    cell.separatorInset = UIEdgeInsetsZero;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CarwashOrderDetailVC *vc = [UIStoryboard vcWithId:@"CarwashOrderDetailVC" inStoryboard:@"Mine"];
    vc.order = [self.orders safetyObjectAtIndex:indexPath.section];
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

@end
