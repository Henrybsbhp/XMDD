//
//  CarwashOrderViewModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarwashOrderViewModel.h"
#import "Xmdd.h"
#import "GetCarwashOrderListV3Op.h"
#import "CarwashOrderDetailVC.h"
#import "PaymentSuccessVC.h"

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
        self.loadingModel.isSectionLoadMore = YES;
    }
    return self;
}

- (void)resetWithTargetVC:(UIViewController *)targetVC
{
    _targetVC = targetVC;
//    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - HKLoadingModelDelegate

-(NSDictionary *)loadingModel:(HKLoadingModel *)model blankImagePromptingWithType:(HKLoadingTypeMask)type
{
    return @{@"title":@"暂无洗车订单",@"image":@"def_withoutOrder"};
}

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @{@"title":@"获取洗车订单失败，点击重试",@"image":@"def_failConnect"};
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    if (type != HKLoadingTypeLoadMore) {
        self.curTradetime = 0;
    }
    
    GetCarwashOrderListV3Op * op = [GetCarwashOrderListV3Op operation];
    op.req_tradetime = self.curTradetime;
    return [[op rac_postRequest] map:^id(GetCarwashOrderListV3Op *rspOp) {
        return rspOp.rsp_orders;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    HKServiceOrder * hkmodel = [model.datasource lastObject];
    self.curTradetime = hkmodel.tradetime;
    [self.tableView reloadData];
}

#pragma mark - Action
- (void)actionCommentForOrder:(HKServiceOrder *)order
{
    PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
    vc.order = order;
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
    return 172;
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
    bottomB.layer.borderWidth = 0.5;
    serviceL.text = order.servicename;
    timeL.text = [order.txtime dateFormatForYYYYMMddHHmm2];
    priceL.text = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:order.fee]];
    paymentL.text = order.paydesc;
    [[RACObserve(order, ratetime) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        [bottomB setTitle:order.ratetime ? @"已评价" : @"去评价" forState:UIControlStateNormal];
        bottomB.layer.borderColor = order.ratetime ? kGrayTextColor.CGColor : kDefTintColor.CGColor;
        UIColor *textColor = order.ratetime ? kGrayTextColor : kDefTintColor;
        [bottomB setTitleColor:textColor forState:UIControlStateNormal];
        bottomB.userInteractionEnabled = !order.ratetime;
    }];
    @weakify(self);
    [[[bottomB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [MobClick event:@"rp318_1"];
        @strongify(self);
        [self actionCommentForOrder:order];
    }];
    
    cell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nestItemCount:1 promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp318_2"];
    CarwashOrderDetailVC *vc = [UIStoryboard vcWithId:@"CarwashOrderDetailVC" inStoryboard:@"Mine"];
    vc.order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    vc.originVC = self.targetVC;
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

@end
