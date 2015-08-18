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
#import "CarwashOrderCommentVC.h"

@interface CarwashOrderViewModel ()
@property (nonatomic, assign) long long curTradetime;
@property (nonatomic, assign) BOOL isRemain;
@end
@implementation CarwashOrderViewModel

- (void)resetWithTargetVC:(UIViewController *)targetVC
{
    _targetVC = targetVC;
    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView setShowBottomLoadingView:YES];
    [self listenNotificationByName:kNotifyRefreshMyCarList withNotifyBlock:^(NSNotification *note, id weakSelf) {
        [weakSelf reloadData];
    }];
}

- (void)reloadData
{
    self.isRemain = YES;
    [self loadDataWithTradetime:0];
}

- (void)loadDataWithTradetime:(long long)tradetime
{
    GetCarwashOrderListOp *op = [GetCarwashOrderListOp new];
    op.req_tradetime = tradetime;
    [[[op rac_postRequest] initially:^{
        
        if (tradetime == 0) {
            [self.tableView.refreshView beginRefreshing];
        }
        else {
            [self.tableView.bottomLoadingView startActivityAnimation];
        }
    }] subscribeNext:^(GetCarwashOrderListOp *rspOp) {

        [self.tableView.refreshView endRefreshing];
        [self.tableView.bottomLoadingView stopActivityAnimation];
        if (tradetime == 0) {
            self.orders = [NSMutableArray array];
        }
        [self.orders safetyAddObjectsFromArray:rspOp.rsp_orders];
        self.curTradetime = [[self.orders lastObject] tradetime];
        //订单列表为空
        if (self.orders.count == 0) {
            self.isRemain = NO;
            [self.tableView.bottomLoadingView hideIndicatorText];
            [self.tableView showDefaultEmptyViewWithText:@"暂无订单"];
        }
        //已经到底了
        else if (rspOp.rsp_orders.count < PageAmount) {
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"没有更多订单了"];
            self.isRemain = NO;
            [self.tableView.superview hideDefaultEmptyView];
        }
        //底下还有订单
        else {
            self.isRemain = YES;
            [self.tableView.superview hideDefaultEmptyView];
        }
        [self.tableView reloadData];
    } error:^(NSError *error) {

        [self.tableView.refreshView endRefreshing];
        [self.tableView.bottomLoadingView stopActivityAnimation];
        [gToast showError:error.domain];
    }];
}

#pragma mark - Action
- (void)actionCommentForOrder:(HKServiceOrder *)order
{
    CarwashOrderCommentVC *vc = [UIStoryboard vcWithId:@"CarwashOrderCommentVC" inStoryboard:@"Mine"];
    vc.order = order;
    [vc setCustomActionBlock:^{
        [self reloadData];
    }];
    [self.targetVC.navigationController pushViewController:vc animated:YES];
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
    [iconV setImageByUrl:[order.shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    
    serviceL.text = order.servicename;
    timeL.text = [order.txtime dateFormatForYYYYMMddHHmm];
    priceL.text = [NSString stringWithFormat:@"￥%.2f", order.fee];
    paymentL.text = [order paymentForCurrentChannel];
    [[RACObserve(order, ratetime) takeUntilForCell:cell] subscribeNext:^(id x) {
        [bottomB setTitle:order.ratetime ? @"已评价" : @"去评价" forState:UIControlStateNormal];
        bottomB.enabled = !order.ratetime;
    }];
    @weakify(self);
    [[[bottomB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [MobClick event:@"rp318-1"];
        @strongify(self);
        [self actionCommentForOrder:order];
    }];
    
    cell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[JTTableViewCell class]]) {
        [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];        
    }
    if (self.orders.count-1 <= indexPath.section && self.isRemain) {
        [self loadMoreData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp318-2"];
    CarwashOrderDetailVC *vc = [UIStoryboard vcWithId:@"CarwashOrderDetailVC" inStoryboard:@"Mine"];
    vc.order = [self.orders safetyObjectAtIndex:indexPath.section];
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

- (void)loadMoreData
{
    if ([self.tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    [self loadDataWithTradetime:self.curTradetime];
}


@end
