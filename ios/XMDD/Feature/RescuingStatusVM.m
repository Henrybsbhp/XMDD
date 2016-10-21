//
//  RescuingStatusVM.m
//  XMDD
//
//  Created by St.Jimmy on 19/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "RescuePaymentStatusVC.h"
#import "RescuingStatusVM.h"
#import "NSString+RectSize.h"
#import "HKProgressView.h"
#import "RescueConfirmFinishOp.h"

@interface RescuingStatusVM () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIViewController *targetVC;

@end

@implementation RescuingStatusVM

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescuingStatusVM is deallocated");
}

- (instancetype)initWithTableView:(UITableView *)tableView andTargetVC:(UIViewController *)targetVC
{
    if (self = [super init]) {
        self.tableView = tableView;
        self.targetVC = targetVC;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    return self;
}

#pragma mark - Initial setup
- (void)initialSetup
{
    if (self.vcType == RescueVCTypeControl) {
        self.dataSource = $($([self setupTopTipsCellWithText:@"支付成功，请耐心等待救援"], [self setupProgressViewCellWithIndex:self.rescueDetialOp.rsp_rescueStatus], [self setupPaymentInfoCellWithArray:@[@"申请服务", self.rescueDetialOp.rsp_serviceName] isHighlighted:NO], [self setupPaymentInfoCellWithArray:@[@"项目价格", [NSString stringWithFormat:@"￥%.2f", self.rescueDetialOp.rsp_pay]] isHighlighted:YES],  [self setupPaymentInfoCellWithArray:@[@"我的车辆", self.rescueDetialOp.rsp_licenseNumber] isHighlighted:NO], [self setupBlankCell], [self setupContactServiceCell]));
    } else {
        self.dataSource = $($([self setupTopTipsCellWithText:@"救援人员已出发，请保持手机畅通"], [self setupProgressViewCellWithIndex:self.vcType], [self setupPaymentInfoCellWithArray:@[@"申请服务", self.rescueDetialOp.rsp_serviceName] isHighlighted:NO], [self setupPaymentInfoCellWithArray:@[@"项目价格", [NSString stringWithFormat:@"￥%.2f", self.rescueDetialOp.rsp_pay]] isHighlighted:YES],  [self setupPaymentInfoCellWithArray:@[@"我的车辆", self.rescueDetialOp.rsp_licenseNumber] isHighlighted:NO], [self setupBlankCell]));
        
        self.confirmButton.enabled = YES;
        
        [[self.confirmButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
            @weakify(self);
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
                @strongify(self);
                [self actionConfirmFinish];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请务必在完成专业救援服务后再确认服务已完成" ActionItems:@[cancel, confirm]];
            [alert show];
        }];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Actions
- (void)actionCallService
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"客服电话：4007-111-111" ActionItems:@[cancel, confirm]];
    [alert show];
}

- (void)actionConfirmFinish
{
    RescueConfirmFinishOp *op = [RescueConfirmFinishOp operation];
    op.req_applyID = self.applyID;
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在确认中..."];
        
    }] subscribeNext:^(RescueConfirmFinishOp *rop) {
        [gToast showSuccess:@"确认完成"];
        RescuePaymentStatusVC *vc = [UIStoryboard vcWithId:@"RescuePaymentStatusVC" inStoryboard:@"Rescue"];
        vc.vcType = RescueVCTypeRating;
        vc.applyID = self.applyID;
        [self.targetVC.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        [gToast showError:@"确认失败，请重试"];
        
    }];
}

#pragma mark - The settings of the UITableViewCell
/// 顶部提示条 Cell
- (CKDict *)setupTopTipsCellWithText:(NSString *)tipsString
{
    CKDict *topTipsCell = [CKDict dictWith:@{kCKItemKey: @"TopTipsCell", kCKCellID: @"TopTipsCell"}];
    topTipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize labelSize = [tipsString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 67 font:[UIFont systemFontOfSize:16]];
        CGFloat height = MAX(50, labelSize.height + 30);
        return height;
    });
    topTipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:101];
        descLabel.text = tipsString;
    });
    
    return topTipsCell;
}

/// 顶部状态进度条 Cell
- (CKDict *)setupProgressViewCellWithIndex:(CGFloat)index
{
    CKDict *progressCell = [CKDict dictWith:@{kCKItemKey: @"ProgressCell", kCKCellID: @"ProgressCell"}];
    progressCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 55;
    });
    
    progressCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        HKProgressView *progressView = (HKProgressView *)[cell.contentView viewWithTag:100];
        progressView.normalColor = kBackgroundColor;
        progressView.normalTextColor = HEXCOLOR(@"#BCBCBC");
        progressView.titleArray = @[@"申请救援", @"救援调整", @"救援中", @"救援完成"];
        progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index)];
    });
    
    return progressCell;
}

/// 支付的信息 Cell
- (CKDict *)setupPaymentInfoCellWithArray:(NSArray *)infoArray isHighlighted:(BOOL)isHighlighted
{
    CKDict *paymentInfoCell = [CKDict dictWith:@{kCKItemKey: @"PaymentInfoCell", kCKCellID: @"PaymentInfoCell"}];
    paymentInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 25;
    });
    paymentInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
        if (isHighlighted) {
            infoLabel.textColor = HEXCOLOR(@"#FF7428");
        }
        
        descLabel.text = infoArray[0];
        infoLabel.text = infoArray[1];
    });
    
    return paymentInfoCell;
}

/// 空白的占位 Cell
- (CKDict *)setupBlankCell
{
    CKDict *blankCell = [CKDict dictWith:@{kCKItemKey: @"BlankCell", kCKCellID: @"BlankCell"}];
    blankCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 10;
    });
    blankCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return blankCell;
}

/// 联系客服 Cell
- (CKDict *)setupContactServiceCell
{
    CKDict *contactServiceCell = [CKDict dictWith:@{kCKItemKey: @"ButtonCell", kCKCellID: @"ButtonCell"}];
    
    contactServiceCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 68;
    });
    
    contactServiceCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIButton *callButton = (UIButton *)[cell.contentView viewWithTag:100];
        
        @weakify(self);
        [[[callButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            [self actionCallService];
        }];
    });
    
    return contactServiceCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

@end
