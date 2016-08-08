//
//  MaintainOrderViewModel.m
//  XMDD
//
//  Created by St.Jimmy on 8/4/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MaintainOrderViewModel.h"
#import "Xmdd.h"
#import "GetCarwashOrderListV3Op.h"
#import "CarwashOrderDetailVC.h"
#import "PaymentSuccessVC.h"

@interface MaintainOrderViewModel () <HKLoadingModelDelegate>

@property (nonatomic, strong) CKList *dataSource;

@property (nonatomic, assign) long long curTradetime;

@end

@implementation MaintainOrderViewModel

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

#pragma mark - HKLoadingModelDelegate

-(NSDictionary *)loadingModel:(HKLoadingModel *)model blankImagePromptingWithType:(HKLoadingTypeMask)type
{
    return @{@"title":@"暂无养护订单",@"image":@"def_withoutOrder"};
}

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    return @{@"title":@"获取养护订单失败，点击重试",@"image":@"def_failConnect"};
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
    [self setDataSource];
}

#pragma mark - Action
- (void)actionCommentForOrder:(HKServiceOrder *)order
{
    PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
    vc.order = order;
    [self.targetVC.navigationController pushViewController:vc animated:YES];
}

- (void)setDataSource
{
    self.dataSource = [CKList list];
    
    for (HKServiceOrder *order in self.loadingModel.datasource) {
    
        CKDict *gasCell = [CKDict dictWith:@{kCKItemKey: @"maintainCell", kCKCellID: @"MaintainCell"}];
        @weakify(self);
        gasCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
            if ([order.statusDesc isEqualToString:@"交易成功"]) {
                return 176;
            }
            
            return 128;
        });
        
        gasCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
            @strongify(self);
            [MobClick event:@"rp318_2"];
            CarwashOrderDetailVC *vc = [UIStoryboard vcWithId:@"CarwashOrderDetailVC" inStoryboard:@"Mine"];
            vc.order = order;
            vc.originVC = self.targetVC;
            [self.targetVC.navigationController pushViewController:vc animated:YES];
        });
        
        gasCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, JTTableViewCell *cell, NSIndexPath *indexPath) {
            UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1001];
            UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:1002];
            UIImageView *brandImageView = (UIImageView *)[cell.contentView viewWithTag:4000];
            UILabel *typeLabel = (UILabel *)[cell.contentView viewWithTag:2002];
            UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:3002];
            UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:2003];
            UIButton *reviewButton = (UIButton *)[cell.contentView viewWithTag:4001];
            UIImageView *separatorImageView = (UIImageView *)[cell.contentView viewWithTag:4002];
            
            reviewButton.layer.cornerRadius = 3;
            reviewButton.layer.borderWidth = 0.5;
            reviewButton.layer.borderColor = HEXCOLOR(@"#18D06A").CGColor;
            reviewButton.layer.masksToBounds = YES;
            
            titleLabel.text = order.shop.shopName;
            statusLabel.text = order.statusDesc;
            [brandImageView setImageByUrl:[order.shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
            typeLabel.text = order.servicename;
            priceLabel.text = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:order.fee]];
            timeLabel.text = [order.txtime dateFormatForYYYYMMddHHmm2];
            
            reviewButton.hidden = [order.statusDesc isEqualToString:@"交易成功"] ? NO : YES;
            separatorImageView.hidden = [order.statusDesc isEqualToString:@"交易成功"] ? NO : YES;
            
            [[RACObserve(order, ratetime) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                [reviewButton setTitle:order.ratetime ? @"已评价" : @"去评价" forState:UIControlStateNormal];
                reviewButton.layer.borderColor = order.ratetime ? kGrayTextColor.CGColor : kDefTintColor.CGColor;
                UIColor *textColor = order.ratetime ? kGrayTextColor : kDefTintColor;
                [reviewButton setTitleColor:textColor forState:UIControlStateNormal];
                reviewButton.userInteractionEnabled = !order.ratetime;
            }];

            [[[reviewButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                [MobClick event:@"rp318_1"];
                @strongify(self);
                [self actionCommentForOrder:order];
            }];
            
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nestItemCount:1 promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.dataSource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block) {
        block(data, indexPath);
    }
}

@end
