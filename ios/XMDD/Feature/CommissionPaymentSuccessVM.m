//
//  PaymentSuccessVM.m
//  XMDD
//
//  Created by St.Jimmy on 20/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "CommissionPaymentSuccessVM.h"
#import "NSString+RectSize.h"
#import "CommissionRecordVC.h"

@interface CommissionPaymentSuccessVM () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIViewController *targetVC;

@end

@implementation CommissionPaymentSuccessVM

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CommissionPaymentSuccessVM is deallocated");
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

- (void)initialSetup
{
    [self setupNavigationBar];
    
    NSString *appointDate = self.commissionDetailOp.rsp_appointTime == 0 ? @"" : [[NSDate dateWithUTS:@(self.commissionDetailOp.rsp_appointTime)] dateFormatForYYMMdd2];
    self.dataSource = $($([self setupTopTipsCellWithText:@"支付成功，请耐心等待救援"],
                          [self setupTitleCell],
                          [self setupPaymentInfoCellWithArray:@[@"申请服务", self.commissionDetailOp.rsp_serviceName] isHighlighted:NO],
                          [self setupPaymentInfoCellWithArray:@[@"项目价格", [NSString stringWithFormat:@"￥%.2f", self.commissionDetailOp.rsp_pay]] isHighlighted:YES],
                          [self setupPaymentInfoCellWithArray:@[@"我的车辆", self.commissionDetailOp.rsp_licenseNumber] isHighlighted:NO],
                          [self setupPaymentInfoCellWithArray:@[@"预约时间", appointDate] isHighlighted:NO],
                          [self setupBlankCell],
                          [self setupTipsCell],
                          [self setupSendCommentCell]));
    
    [self.tableView reloadData];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.targetVC.navigationItem.leftBarButtonItem = back;
    [self.targetVC.navigationController.interactivePopGestureRecognizer addTarget:self action:@selector(actionBack)];
}

#pragma mark - Actions
- (void)actionContactService
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"客服电话：4007-111-111" ActionItems:@[cancel, confirm]];
    [alert show];
}

- (void)actionBack
{
    for (UIViewController *vc in self.targetVC.navigationController.viewControllers) {
        if ([vc isKindOfClass:[CommissionRecordVC class]]) {
            [self.targetVC.router.navigationController popToViewController:vc animated:YES];
        }
    }
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

/// 顶部 Title Cell
- (CKDict *)setupTitleCell
{
    CKDict *titleCell = [CKDict dictWith:@{kCKItemKey: @"TitleCell", kCKCellID: @"TitleCell"}];
    
    titleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 56;
    });
    
    titleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return titleCell;
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

/// 提示语 Cell
- (CKDict *)setupTipsCell
{
    NSString *tipsString = @"客服会在您预约的时间前一天与您联系，请保持手机畅通";
    CKDict *tipsCell = [CKDict dictWith:@{kCKItemKey: @"SecondTipsCell", kCKCellID: @"SecondTipsCell"}];
    
    tipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize labelSize = [tipsString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 34 font:[UIFont systemFontOfSize:13]];
        CGFloat height = MAX(30, labelSize.height + 10);
        
        return height;
    });
    
    tipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *tipsLabel = (UILabel *)[cell.contentView searchViewWithTag:100];
        
        tipsLabel.text = tipsString;
    });
    
    return tipsCell;
}

/// 联系客服 Cell
- (CKDict *)setupSendCommentCell
{
    CKDict *sendCommentCell = [CKDict dictWith:@{kCKItemKey: @"ButtonCell", kCKCellID: @"ButtonCell"}];
    
    sendCommentCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 68;
    });
    
    sendCommentCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIButton *sendButton = (UIButton *)[cell.contentView viewWithTag:100];
        
        @weakify(self);
        [[[sendButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            [self actionContactService];
        }];
    });
    
    return sendCommentCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

@end
