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
#import "InsuranceOrderVC.h"
#import "PayForInsuranceVC.h"
#import "InsOrderStore.h"

@interface InsranceOrderViewModel ()<HKLoadingModelDelegate>

@end

@implementation InsranceOrderViewModel

- (id)initWithTableView:(JTTableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showBottomLoadingView = YES;
        self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
        [self setupInsOrderStore];
    }
    return self;
}

- (void)resetWithTargetVC:(UIViewController *)targetVC
{
    _targetVC = targetVC;
    //    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
}

- (void)setupInsOrderStore
{
    [[InsOrderStore fetchOrCreateStore] subscribeEventsWithTarget:self receiver:^(CKStore *store, RACSignal *evt, NSInteger code) {
        if (code != kCKStoreEventReload) {
            evt = [evt map:^id(id value) {
                return [[(InsOrderStore *)store cache] allObjects];
            }];
        }
        [self.loadingModel reloadDataFromSignal:evt];
    }];
}

#pragma mark - Action
- (void)actionMakeCall:(id)sender
{
    [gPhoneHelper makePhone:@"4007111111" andInfo:@"咨询电话：4007-111-111"];
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"暂无保险订单";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取保险订单失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    return [[InsOrderStore fetchExistsStore] rac_getAllInsOrders];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    [self.tableView reloadData];
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
    return 152;
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
    UILabel *contentL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *timeL = (UILabel *)[cell.contentView viewWithTag:2003];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:3002];
    UIButton *bottomB = (UIButton *)[cell.contentView viewWithTag:4001];
    
    HKInsuranceOrder *order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    nameL.text = order.inscomp;
//    nameL.text = [order descForCurrentInstype];
    contentL.text = order.serviceName;
//    contentL.text = [order generateContent];
    
    stateL.text = [order descForCurrentStatus]; //老方式，已经用新字段替换
    timeL.text = [order.lstupdatetime dateFormatForYYYYMMddHHmm];
    priceL.text = [NSString stringWithFormat:@"￥%d", (int)(order.fee)];
    
    BOOL unpaid = order.status == InsuranceOrderStatusUnpaid;
    [bottomB setTitle:unpaid ? @"买了" : @"联系客服" forState:UIControlStateNormal];
    [bottomB setTitleColor:unpaid ? RGBCOLOR(251, 88, 15) : RGBCOLOR(21, 172, 31) forState:UIControlStateNormal];
    
    bottomB.layer.borderColor = unpaid ? [RGBCOLOR(251, 88, 15) CGColor] : [RGBCOLOR(21, 172, 31) CGColor];
    
     @weakify(self);
    [[[bottomB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
        @strongify(self);
         if (unpaid) {
             [MobClick event:@"rp318-6"];
             PayForInsuranceVC * vc = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"PayForInsuranceVC"];
             vc.insOrder = order;
             vc.originVC = self.targetVC;
             [self.targetVC.navigationController pushViewController:vc animated:YES];
         }
         else {
             [MobClick event:@"rp318-5"];
             [self actionMakeCall:x];
         }
    }];
    cell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:NO promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKInsuranceOrder * order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    InsuranceOrderVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderVC" inStoryboard:@"Insurance"];
    vc.order = order;
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

@end
