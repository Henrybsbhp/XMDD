//
//  GasOrderModelView.m
//  XMDD
//
//  Created by St.Jimmy on 8/3/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GasOrderModelView.h"
#import "GasChargeOrderOp.h"
#import "GasChargedOrderModel.h"
#import "NSString+Split.h"

@interface GasOrderModelView () <HKLoadingModelDelegate>

@property (nonatomic, strong) CKList *dataSource;

@property (nonatomic, assign) long long payedTime;

@end

@implementation GasOrderModelView

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
/// 跳转到详情
- (void)actionJumpToDetailVCWithModel:(GasChargedOrderModel *)model
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"订单详情";
    vc.url = [OrderDetailsUrl stringByAppendingString:[NSString stringWithFormat:@"?token=%@&oid=%ld&tradetype=%@",gNetworkMgr.token ,(long)model.orderID, model.tradeType]];
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

#pragma mark - HKLoadingModelDelegate

-(NSDictionary *)loadingModel:(HKLoadingModel *)model blankImagePromptingWithType:(HKLoadingTypeMask)type
{
    return @{@"title":@"暂无加油订单",@"image":@"def_withoutOrder"};
}

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @{@"title":@"获取加油订单失败，点击重试",@"image":@"def_failConnect"};
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    if (type != HKLoadingTypeLoadMore) {
        self.payedTime = 0;
    }
    
    GasChargeOrderOp *op = [GasChargeOrderOp operation];
    op.payedTime = self.payedTime;
    return [[op rac_postRequest] map:^id(GasChargeOrderOp *rspOp) {
        return rspOp.gasChargedData;
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    GasChargedOrderModel * gasOrderModel = [model.datasource lastObject];
    self.payedTime = gasOrderModel.payedTime;
    [self setDataSource];
}

#pragma mark - The settings of dataSource
- (void)setDataSource
{
    self.dataSource = [CKList list];
    
    for (GasChargedOrderModel *order in self.loadingModel.datasource) {
        @weakify(self);
        CKDict *gasCell = [CKDict dictWith:@{kCKItemKey: @"gasCell", kCKCellID: @"GasCell"}];
        gasCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            return 173;
        });
        
        gasCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
            @strongify(self);
            if ([order.tradeType isEqualToString:@"FQJY"]) {
                [self actionJumpToDetailVCWithModel:order];
            }
        });
        
        gasCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
            UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1001];
            UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:1002];
            UIImageView *brandImageView = (UIImageView *)[cell.contentView viewWithTag:2001];
            UILabel *cardNumLabel = (UILabel *)[cell.contentView viewWithTag:2002];
            UILabel *originalPriceLabel = (UILabel *)[cell.contentView viewWithTag:3002];
            UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:2003];
            UILabel *fastPayDescLabel = (UILabel *)[cell.contentView viewWithTag:3003];
            UILabel *payPrice = (UILabel *)[cell.contentView viewWithTag:4001];
            
            NSDate *date = [NSDate dateWithUTS:@(order.payedTime)];
            if (order.cardType == 1) {
                brandImageView.image = [UIImage imageNamed:@"gas_icon_cnpc"];
            } else {
                brandImageView.image = [UIImage imageNamed:@"gas_icon_snpn"];
            }
            
            titleLabel.text = order.cardType == 1 ? @"中石油" : @"中石化";
            statusLabel.text = order.statusDesc;
            cardNumLabel.text = [order.gasCardNum splitByStep:4 replacement:@" "];
            originalPriceLabel.text = [NSString stringWithFormat:@"¥%.0f", order.chargeMoney];
            timeLabel.text = [date dateFormatForYYYYMMddHHmm2];
            fastPayDescLabel.text = order.chargeTips;
            payPrice.text = [NSString stringWithFormat:@"支付金额：¥%.0f", order.payMoney];
        });
        
        [self.dataSource addObject:$(gasCell) forKey:nil];
    }
    
    [self.tableView reloadData];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nestItemCount:1 promptView:self.tableView.bottomLoadingView];
}

@end
