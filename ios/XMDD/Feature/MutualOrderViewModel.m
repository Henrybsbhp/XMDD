//
//  MutualOrderViewModel.m
//  XMDD
//
//  Created by St.Jimmy on 8/3/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualOrderViewModel.h"
#import "MutualOrderListGetOp.h"
#import "MutualOrderListModel.h"
#import "MutualInsOrderInfoVC.h"

@interface MutualOrderViewModel () <HKLoadingModelDelegate>

@property (nonatomic, strong) CKList *dataSource;

@end

@implementation MutualOrderViewModel

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
}

#pragma mark - Actions
- (void)actionGoToMutualInsOrderInfoVCWithModel:(MutualOrderListModel *)model
{
    
}

#pragma mark - HKLoadingModelDelegate

-(NSDictionary *)loadingModel:(HKLoadingModel *)model blankImagePromptingWithType:(HKLoadingTypeMask)type
{
    return @{@"title":@"暂无互助订单",@"image":@"def_withoutOrder"};
}

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @{@"title":@"获取互助订单失败，点击重试",@"image":@"def_failConnect"};
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    MutualOrderListGetOp * op = [MutualOrderListGetOp operation];
    return [[op rac_postRequest] map:^id(MutualOrderListGetOp *rspOp) {
        return rspOp.cooperationData;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    [self setDataSource];
}

- (void)setDataSource
{
    self.dataSource = [CKList list];
    
    for (MutualOrderListModel *order in self.loadingModel.datasource) {
        if (!order.forceInfo) {
            [self.dataSource addObject:$([self setupMutualCellWithModel:order]) forKey:nil];
        } else {
            [self.dataSource addObject:$([self setupMutualCompletedCellWithModel:order]) forKey:nil];
        }
    }
    
    [self.tableView reloadData];
}

- (CKDict *)setupMutualCellWithModel:(MutualOrderListModel *)model
{
    CKDict *mutualCell = [CKDict dictWith:@{kCKItemKey: @"mutualCell", kCKCellID: @"MutualCell"}];
    @weakify(self);
    mutualCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 219;
    });
    
    mutualCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [self actionGoToMutualInsOrderInfoVCWithModel:model];
    });
    
    mutualCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:1002];
        UIImageView *brandImageView = (UIImageView *)[cell.contentView viewWithTag:2001];
        UILabel *carNumLabel = (UILabel *)[cell.contentView viewWithTag:2002];
        UILabel *mutualPriceLabel = (UILabel *)[cell.contentView viewWithTag:3002];
        UILabel *mutualTimeLabel = (UILabel *)[cell.contentView viewWithTag:2003];
        UILabel *mutualDescLabel = (UILabel *)[cell.contentView viewWithTag:3003];
        UILabel *startTimeLabel = (UILabel *)[cell.contentView viewWithTag:4001];
        UILabel *endTimeLabel = (UILabel *)[cell.contentView viewWithTag:4002];
        UILabel *servicePriceLabel = (UILabel *)[cell.contentView viewWithTag:5001];
        UILabel *serviceDescLabel = (UILabel *)[cell.contentView viewWithTag:5002];
        UILabel *sumLabel = (UILabel *)[cell.contentView viewWithTag:6001];
        
        [brandImageView setImageByUrl:model.brandLogoAddress withType:ImageURLTypeOrigin defImage:@"cm_shop" errorImage:@"cm_shop"];
        brandImageView.contentMode = UIViewContentModeScaleAspectFit;
        titleLabel.text = @"小马互助";
        statusLabel.text = model.statusDesc;
        carNumLabel.text = model.licenseNumber;
        mutualPriceLabel.text = [NSString stringWithFormat:@"¥%@", model.sharedMoney];
        mutualTimeLabel.text = model.createTime;
        mutualDescLabel.text = @"互助金";
        startTimeLabel.text = [NSString stringWithFormat:@"保障开始：%@", model.insStartTime];
        endTimeLabel.text = [NSString stringWithFormat:@"保障结束：%@", model.insEndTime];
        servicePriceLabel.text = [NSString stringWithFormat:@"¥%@", model.memberFee];
        serviceDescLabel.text = @"服务费";
        sumLabel.text = [NSString stringWithFormat:@"¥%@", model.fee];
    });
    
    return mutualCell;
}

- (CKDict *)setupMutualCompletedCellWithModel:(MutualOrderListModel *)model
{
    CKDict *mutualCompletedCell = [CKDict dictWith:@{kCKItemKey: @"mutualCompletedCell", kCKCellID: @"MutualCompletedCell"}];
    @weakify(self);
    mutualCompletedCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 330;
    });
    
    mutualCompletedCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [self actionGoToMutualInsOrderInfoVCWithModel:model];
    });
    
    mutualCompletedCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:1002];
        UIImageView *brandImageView = (UIImageView *)[cell.contentView viewWithTag:2001];
        UILabel *carNumLabel = (UILabel *)[cell.contentView viewWithTag:2002];
        UILabel *mutualPriceLabel = (UILabel *)[cell.contentView viewWithTag:3002];
        UILabel *mutualTimeLabel = (UILabel *)[cell.contentView viewWithTag:2003];
        UILabel *mutualDescLabel = (UILabel *)[cell.contentView viewWithTag:3003];
        UILabel *startTimeLabel = (UILabel *)[cell.contentView viewWithTag:4001];
        UILabel *endTimeLabel = (UILabel *)[cell.contentView viewWithTag:4002];
        UILabel *servicePriceLabel = (UILabel *)[cell.contentView viewWithTag:5001];
        UILabel *serviceDescLabel = (UILabel *)[cell.contentView viewWithTag:5002];
        UILabel *sumLabel = (UILabel *)[cell.contentView viewWithTag:6001];
        
        [brandImageView setImageByUrl:model.brandLogoAddress withType:ImageURLTypeOrigin defImage:@"cm_shop" errorImage:@"cm_shop"];
        brandImageView.contentMode = UIViewContentModeScaleAspectFit;
        titleLabel.text = @"小马互助";
        statusLabel.text = model.statusDesc;
        carNumLabel.text = model.licenseNumber;
        mutualPriceLabel.text = [NSString stringWithFormat:@"¥%@", model.sharedMoney];
        mutualTimeLabel.text = model.createTime;
        mutualDescLabel.text = @"互助金";
        startTimeLabel.text = [NSString stringWithFormat:@"保障开始：%@", model.insStartTime];
        endTimeLabel.text = [NSString stringWithFormat:@"保障结束：%@", model.insEndTime];
        servicePriceLabel.text = [NSString stringWithFormat:@"¥%@", model.memberFee];
        serviceDescLabel.text = @"服务费";
        sumLabel.text = [NSString stringWithFormat:@"¥%@", model.fee];
        
        UIImageView *brandImageView2 = (UIImageView *)[cell.contentView viewWithTag:7001];
        UILabel *insuranceLabel = (UILabel *)[cell.contentView viewWithTag:7002];
        UILabel *insuranceTimeLabel = (UILabel *)[cell.contentView viewWithTag:7003];
        UILabel *insForceFeelabel = (UILabel *)[cell.contentView viewWithTag:7004];
        UILabel *insTaxShipFeeLabel = (UILabel *)[cell.contentView viewWithTag:7007];
        UILabel *insForceFeeDescLabel = (UILabel *)[cell.contentView viewWithTag:7005];
        UILabel *insTaxShipFeeDescLabel = (UILabel *)[cell.contentView viewWithTag:7009];
        UILabel *insStartTimeLabel = (UILabel *)[cell.contentView viewWithTag:7006];
        UILabel *insEndTimeLabel = (UILabel *)[cell.contentView viewWithTag:7008];
        
        [brandImageView2 setImageByUrl:model.forceInfo.proxyLogo withType:ImageURLTypeOrigin defImage:@"cm_shop" errorImage:@"cm_shop"];
        brandImageView2.contentMode = UIViewContentModeScaleAspectFit;
        insuranceLabel.text = model.forceInfo.insComp;
        insuranceTimeLabel.text = model.forceInfo.createTime;
        insForceFeelabel.text = [NSString stringWithFormat:@"¥%@", model.forceInfo.forceFee];
        insForceFeeDescLabel.text = @"交强险";
        insStartTimeLabel.text = [NSString stringWithFormat:@"保障开始：%@", model.forceInfo.forceStartDate];
        insEndTimeLabel.text = [NSString stringWithFormat:@"保障开始：%@", model.forceInfo.forceEndDate];
        insTaxShipFeeLabel.text = [NSString stringWithFormat:@"¥%@", model.forceInfo.taxShipFee];
        insTaxShipFeeDescLabel.text = @"车船税";
    });
    
    return mutualCompletedCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    
    return 219;
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
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    JTTableViewCell *cell = (JTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    if (item[kCKCellSelected]) {
        ((CKCellSelectedBlock)item[kCKCellSelected])(item, indexPath);
    }
}

@end
