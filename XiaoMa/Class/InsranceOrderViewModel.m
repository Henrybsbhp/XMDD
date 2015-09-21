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
#import "InsuranceOrderVC.h"

@interface InsranceOrderViewModel ()<HKLoadingModelDelegate>

@property (nonatomic, assign) long long curTradetime;

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
    return @"暂无保险订单";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    return @"获取保险订单失败，点击重试";
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    if (type != HKDatasourceLoadingTypeLoadMore) {
        self.curTradetime = 0;
    }

    
    GetInsuranceOrderListOp * op = [GetInsuranceOrderListOp operation];
    return [[op rac_postRequest] map:^id(GetInsuranceOrderListOp *rspOp) {
        return rspOp.rsp_orders;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate and UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.loadingModel.datasource.count;
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
    stateL.text = [order getStatusString];
    contentL.text = order.serviceName;
    timeL.text = [order.lstupdatetime dateFormatForYYYYMMddHHmm];
    priceL.text = [NSString stringWithFormat:@"￥%d", (int)(order.policy.premium)];
    if (order.status == 2) {
        [bottomB setTitle:@"买了" forState:UIControlStateNormal];
    }
    else {
        [bottomB setTitle:@"买了" forState:UIControlStateNormal];
        [[[bottomB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]subscribeNext:^(id x) {
            
        }];
    }
    
    cell.separatorInset = UIEdgeInsetsZero;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [(JTTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:NO promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InsuranceOrderVC *vc = [UIStoryboard vcWithId:@"InsuranceOrderVC" inStoryboard:@"Insurance"];
    vc.order = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

@end
