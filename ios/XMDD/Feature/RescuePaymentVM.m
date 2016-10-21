//
//  RescuePaymentVM.m
//  XMDD
//
//  Created by St.Jimmy on 18/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "RescuePaymentVM.h"
#import "HKProgressView.h"
#import "UPApplePayHelper.h"
#import "NSString+RectSize.h"

@interface RescuePaymentVM () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIViewController *targetVC;

/// 支付数据源
@property (nonatomic, copy) NSArray *paymentArray;

@end

@implementation RescuePaymentVM

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescuePaymentVM is deallocated");
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
    [self setupPaymentArray];
    
    self.dataSource = $($([self setupTopTipsCellWithText:@"支付成功，请耐心等待救援"], [self setupProgressViewCellWithIndex:1], [self setupPaymentInfoCellWithArray:@[@"申请服务", @"拖车服务"] isHighlighted:NO], [self setupPaymentInfoCellWithArray:@[@"项目价格", @"￥300.00"] isHighlighted:YES],  [self setupPaymentInfoCellWithArray:@[@"我的车辆", @"浙AJC625"] isHighlighted:NO], [self setupBlankCell]), $([self setupPaymentTitleCell], [self setupPaymentPlatformCell], [self setupPaymentPlatformCell], [self setupPaymentPlatformCell], [self setupPaymentPlatformCell]));
}

#pragma mark = Initial Setup
- (void)setupPaymentArray
{
    NSDictionary * alipay = @{@"title":@"支付宝支付",
                              @"payment":@(PaymentChannelAlipay),@"recommend":@(NO),
                              @"cellname":@"PaymentPlatformCell",@"icon":@"alipay_logo_66",@"uppayrecommend":@(NO)};
    
    NSDictionary * wechat = @{@"title":@"微信支付",
                              @"payment":@(PaymentChannelWechat),@"recommend":@(NO),
                              @"cellname":@"PaymentPlatformCell",@"icon":@"wechat_logo_66",@"uppayrecommend":@(NO)};
    
    NSDictionary * uppay = @{@"title":@"银联在线支付",
                             @"payment":@(PaymentChannelUPpay),@"recommend":@(YES),
                             @"cellname":@"PaymentPlatformCell",@"icon":@"uppay_logo_66",@"uppayrecommend":@(NO)};
    
    NSDictionary * apple = @{@"title":@"Apple Pay",
                             @"payment":@(PaymentChannelApplePay),@"recommend":@(NO),
                             @"cellname":@"PaymentPlatformCell",@"icon":@"apple_pay_logo_66",@"uppayrecommend":@(YES)};
    
    NSMutableArray * array = [NSMutableArray array];
    
    [array safetyAddObject:uppay];
    if ([UPApplePayHelper isApplePayAvailable]) {
        [array safetyAddObject:apple];
    }
    [array safetyAddObject:alipay];
    if (gPhoneHelper.exsitWechat) {
        [array safetyAddObject:wechat];
    }
    
    self.paymentArray = [NSArray arrayWithArray:array];
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

/// 支付平台 Section 的标题 Cell
- (CKDict *) setupPaymentTitleCell
{
    CKDict *paymentTitleCell = [CKDict dictWith:@{kCKItemKey: @"PaymentTitleCell", kCKCellID: @"PaymentTitleCell"}];
    paymentTitleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    paymentTitleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return paymentTitleCell;
}

/// 银联和 Apple Pay 设置 Cell
- (CKDict *)setupPaymentPlatformCell
{
    @weakify(self);
    CKDict *paymentPlatformCell = [CKDict dictWith:@{kCKItemKey: @"PaymentPlatformCell", kCKCellID: @"PaymentPlatformCell"}];
    paymentPlatformCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        if (![UPApplePayHelper isApplePayAvailable] || !gPhoneHelper.exsitWechat) {
            return 0;
        }
        return 50;
    });
    paymentPlatformCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIImageView *iconImgView = (UIImageView *)[cell.contentView viewWithTag:1001];
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1002];
        UIImageView *selMarkImgView = (UIImageView *)[cell.contentView viewWithTag:1003];
        UILabel *recommendedLabel = (UILabel *)[cell.contentView viewWithTag:1005];
        UIImageView *uppayIconImgView = (UIImageView *)[cell.contentView viewWithTag:1006];
        
        NSDictionary *paymentDict = [self.paymentArray safetyObjectAtIndex:indexPath.row - 1];
        PaymentChannelType paychannel = [paymentDict integerParamForName:@"payment"];
        
        recommendedLabel.cornerRadius = 3.0f;
        recommendedLabel.layer.masksToBounds = YES;
        
        iconImgView.image = [UIImage imageNamed:paymentDict[@"icon"]];
        titleLabel.text = paymentDict[@"title"];
        recommendedLabel.hidden = ![paymentDict boolParamForName:@"recommend"];
        uppayIconImgView.hidden = ![paymentDict boolParamForName:@"uppayrecommend"];
        titleLabel.textColor = kDarkTextColor;
    });
    
    return paymentPlatformCell;
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
