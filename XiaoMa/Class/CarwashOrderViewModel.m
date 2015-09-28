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

@interface CarwashOrderViewModel ()<HKLoadingModelDelegate>

@property (nonatomic, assign) long long curTradetime;

@end
@implementation CarwashOrderViewModel

- (id)initWithTableView:(JTTableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showBottomLoadingView = YES;
        self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    }
    return self;
}

- (void)resetWithTargetVC:(UIViewController *)targetVC
{
    _targetVC = targetVC;
//    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"暂无洗车订单";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取洗车订单失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    if (type != HKDatasourceLoadingTypeLoadMore) {
        self.curTradetime = 0;
    }
    
    GetCarwashOrderListOp * op = [GetCarwashOrderListOp operation];
    op.req_tradetime = self.curTradetime;
    return [[op rac_postRequest] map:^id(GetCarwashOrderListOp *rspOp) {
        return rspOp.rsp_orders;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    HKServiceOrder * hkmodel = [model.datasource lastObject];
    self.curTradetime = hkmodel.tradetime;
    [self.tableView reloadData];
}

#pragma mark - Action
- (void)actionCommentForOrder:(HKServiceOrder *)order
{
    CarwashOrderCommentVC *vc = [UIStoryboard vcWithId:@"CarwashOrderCommentVC" inStoryboard:@"Mine"];
    vc.order = order;
    [vc setCustomActionBlock:^{
        //[self.tableView.refreshView beginRefreshing];
    }];
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate and UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.loadingModel.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 162;
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
    
    HKServiceOrder *order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    
    nameL.text = order.shop.shopName;
    stateL.text = @"交易成功";
    [iconV setImageByUrl:[order.shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    
    serviceL.text = order.servicename;
    timeL.text = [order.txtime dateFormatForYYYYMMddHHmm];
    priceL.text = [NSString stringWithFormat:@"￥%.2f", order.fee];
    paymentL.text = order.paydesc;
    [[RACObserve(order, ratetime) takeUntilForCell:cell] subscribeNext:^(id x) {
        [bottomB setTitle:order.ratetime ? @"已评价" : @"去评价" forState:UIControlStateNormal];
        bottomB.userInteractionEnabled = !order.ratetime;
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
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:NO promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp318-2"];
    CarwashOrderDetailVC *vc = [UIStoryboard vcWithId:@"CarwashOrderDetailVC" inStoryboard:@"Mine"];
    vc.order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

@end
