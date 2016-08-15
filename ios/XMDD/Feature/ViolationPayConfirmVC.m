//
//  ViolationPayConfirmVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ViolationPayConfirmVC.h"
#import "ChooseCouponVC.h"

#import "HKCoupon.h"
#import "PaymentHelper.h"
#import "UPApplePayHelper.h"

#import "OrderPaidSuccessOp.h"
#import "PayViolationCommissionOrderOp.h"
#import "GetViolationCommissionCouponsOp.h"
#import "ConfirmViolationCommissionOrderConfirmOp.h"

@interface ViolationPayConfirmVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (assign, nonatomic) BOOL isLoadingResourse;

@property (strong, nonatomic) NSNumber *money;
@property (strong, nonatomic) NSNumber *serviceFee;
@property (strong, nonatomic) NSNumber *totalFee;
@property (strong, nonatomic) NSString *serviceName;
@property (strong, nonatomic) NSString *servicePicURL;
@property (strong, nonatomic) NSArray *couponArray;
@property (strong, nonatomic) NSMutableArray *selectCoupouArray;

/**
 *  数据源
 */
@property (strong, nonatomic) CKList *dataSource;
@property (assign, nonatomic) PaymentChannelType paychannel;

///支付数据源
@property (nonatomic,strong)NSArray * paymentArray;

@end

@implementation ViolationPayConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getViolationCommissionCoupons];
    [self confirmViolationCommissionOrderConfirm];
    [self setupDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshBottomView];
    [self.tableView reloadData];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"ViolationPayConfirmVC dealloc");
}


#pragma mark - Setup

- (void)setupDataSource
{
    
    self.paychannel = PaymentChannelUPpay;
    
    CKDict *applePayData = [self payPlatformCellDataWithPayChannelData:@{@"logo" : @"apple_pay_logo_66",
                                                                         @"name" : @"Apple Pay",
                                                                         @"isRecommend" : @(NO),
                                                                         @"type" : @(PaymentChannelApplePay),
                                                                         @"isApplePay" : @(YES)}];
    CKDict *wechatData = [self payPlatformCellDataWithPayChannelData:@{@"logo" : @"wechat_logo_66",
                                                                       @"name" : @"微信支付",
                                                                       @"isRecommend" : @(NO),
                                                                       @"type" : @(PaymentChannelWechat),
                                                                       @"isApplePay" : @(NO)}];
    
    self.dataSource = $(
                        $(
                          [self titleCellData],
                          [self shopItemCellData],
                          [self itemFeeCellDataWithItem:@"违章罚款"],
                          [self itemFeeCellDataWithItem:@"手续费"],
                          [self itemFeeCellDataWithItem:@"合计金额"],
                          [self blankCellData]
                          ),
                        $(
                          [self couponHeadCellData],
                          [self couponCellData]
                          ),
                        $(
                          [self otherCellData],
                          [self payPlatformCellDataWithPayChannelData:@{@"logo" : @"illegal_upayLogo",
                                                                        @"name" : @"银联在线支付",
                                                                        @"isRecommend" : @(YES),
                                                                        @"type" : @(PaymentChannelUPpay),
                                                                        @"isApplePay" : @(NO)}],
                          ([UPApplePayHelper isApplePayAvailable] ? applePayData : CKNULL),
                          [self payPlatformCellDataWithPayChannelData:@{@"logo" : @"alipay_logo_66",
                                                                        @"name" : @"支付宝支付",
                                                                        @"isRecommend" : @(NO),
                                                                        @"type" : @(PaymentChannelAlipay),
                                                                        @"isApplePay" : @(NO)}],
                          (gPhoneHelper.exsitWechat ? wechatData : CKNULL)
                          )
                        );
}

- (void)setupUI
{
    self.button.layer.cornerRadius = 5;
    self.button.layer.masksToBounds = YES;
}

#pragma mark - Network

- (BOOL)callPaymentHelperWithPayOp:(PayViolationCommissionOrderOp *)paidop
{
    
    if (paidop.rsp_totalfee == 0) {
        return NO;
    }
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    
    NSString *text;
    switch ([paidop.req_paychannel integerValue]) {
        case PaymentChannelAlipay: {
            text = @"订单生成成功,正在跳转到支付宝平台进行支付";
            [helper resetForAlipayWithTradeNumber:paidop.rsp_tradeno  alipayInfo:paidop.rsp_payInfoModel.alipayInfo];;
        } break;
        case PaymentChannelWechat: {
            text = @"订单生成成功,正在跳转到微信平台进行支付";
            [helper resetForWeChatWithTradeNumber:paidop.rsp_tradeno andPayInfoModel:paidop.rsp_payInfoModel.wechatInfo andTradeType:TradeTypeViolation];
        } break;
        case PaymentChannelUPpay: {
            text = @"订单生成成功,正在跳转到银联平台进行支付";
            [helper resetForUPPayWithTradeNumber:paidop.rsp_tradeno targetVC:self];
        } break;
        case PaymentChannelApplePay:{
            
            [helper resetForUPApplePayWithTradeNumber:paidop.rsp_tradeno targetVC:self];
        } break;
        default:
            return NO;
    }
    if (text.length)
    {
        [gToast showText:text];
    }
    __block BOOL paidSuccess = NO;
    @weakify(self);
    [[helper rac_startPay] subscribeNext:^(id x) {
        
        @strongify(self);
        OrderPaidSuccessOp *op = [OrderPaidSuccessOp operation];
        op.req_notifytype = 7;
        op.req_tradeno = paidop.rsp_tradeno;
        [[op rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"已通知服务器支付成功!");
        }];
        // 支付成功
        paidSuccess = YES;
        
        NSString * couponInfo;
        if ([x isKindOfClass:[PaymentHelper class]])
        {
            PaymentHelper * helper = (PaymentHelper *)x;
            couponInfo = helper.uppayCouponInfo;
        }
        
        [self paySuccess];
        
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        
    }];
    return YES;
}

- (void)payViolationCommissionOrder
{
    
    @weakify(self)
    
    PayViolationCommissionOrderOp *op = [PayViolationCommissionOrderOp operation];
    
    op.req_paychannel = @(self.paychannel);
    op.req_recordid = self.recordID;
    HKCoupon *coupon = self.selectCoupouArray.firstObject;
    op.req_couponid = coupon.couponId.stringValue;
    
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"订单生成中..."];
        
    }]subscribeNext:^(PayViolationCommissionOrderOp *op) {
        
        @strongify(self)
        
        [self callPaymentHelperWithPayOp:op];
        
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        
    }];
    
}

- (void)getViolationCommissionCoupons
{
    @weakify(self)
    
    GetViolationCommissionCouponsOp *op = [GetViolationCommissionCouponsOp operation];
    
    [[[op rac_postRequest]initially:^{
        
        @strongify(self)
        
        self.isLoadingResourse = NO;
    }]subscribeNext:^(GetViolationCommissionCouponsOp *op) {
        
        @strongify(self)
        
        self.isLoadingResourse = YES;
        self.couponArray = op.rsp_coupons;
    } error:^(NSError *error) {
        
        @strongify(self)
        
        self.isLoadingResourse = NO;
        
    }];
    
}

- (void)confirmViolationCommissionOrderConfirm
{
    @weakify(self)
    ConfirmViolationCommissionOrderConfirmOp *op = [ConfirmViolationCommissionOrderConfirmOp operation];
    
    op.req_recordid = self.recordID;
    
    [[[op rac_postRequest]initially:^{
        
        @strongify(self)
        
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        self.tableView.hidden = YES;
        self.bottomView.hidden = YES;
        
    }]subscribeNext:^(ConfirmViolationCommissionOrderConfirmOp *op) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
        self.bottomView.hidden = NO;
        
        self.money = op.rsp_money;
        self.serviceFee = op.rsp_servicefee;
        self.totalFee = op.rsp_totalfee;
        
        [self refreshBottomView];
        [self.tableView reloadData];
        
        
    } error:^(NSError *error) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"支付信息请求失败。点击重试" tapBlock:^{
            
            @strongify(self)
            
            [self confirmViolationCommissionOrderConfirm];
            
        }];
        
    }];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(CKList *)self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    if (block) {
        block(item, cell, indexPath);
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    if (block) {
        return block(item, indexPath);
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = item[kCKCellSelected];
    if (block) {
        block(item, indexPath);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - Cell

- (CKDict *)couponHeadCellData
{
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"CouponHeadCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 42;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        UIActivityIndicatorView *indicatorView = [cell viewWithTag:202];
        
        
        [[RACObserve(self, isLoadingResourse) distinctUntilChanged] subscribeNext:^(NSNumber * number) {
            
            BOOL isloading = [number boolValue];
            indicatorView.animating = !isloading;
            indicatorView.hidden = isloading;
            
        }];
        
    });
    
    return data;
}

- (CKDict *)payPlatformCellDataWithPayChannelData:(NSDictionary *)payChannelData
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"PaymentPlatformCell"}];

    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });

    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {

        @strongify(self)
        
        UIImageView *channelLogo = [cell viewWithTag:1001];
        channelLogo.image = [UIImage imageNamed:payChannelData[@"logo"]];

        UILabel *channelName = [cell viewWithTag:1002];
        channelName.text = payChannelData[@"name"];

        UIImageView *selectView = [cell viewWithTag:1003];
        selectView.hidden = !([(NSNumber *)payChannelData[@"type"] integerValue] == self.paychannel);

        UIImageView *recommendView = [cell viewWithTag:1005];
        recommendView.layer.cornerRadius = 3;
        recommendView.layer.masksToBounds = YES;
        recommendView.hidden = ![(NSNumber *)payChannelData[@"isRecommend"] boolValue];
        
        UIImageView *uPayView = [cell viewWithTag:1006];
        uPayView.hidden = ![(NSNumber *)payChannelData[@"isApplePay"] boolValue];
        
    });

    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {

        @strongify(self)

        self.paychannel = [(NSNumber *)payChannelData[@"type"] integerValue];

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];

    });
    
    return data;
}

- (CKDict *)blankCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"BlankCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 12;
    });
    
    return data;
}

- (CKDict *)titleCellData
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"ShopTitleCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 68;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        UIImageView *logoView = [cell viewWithTag:100];
        [[gMediaMgr rac_getGifImageDataByUrl:self.servicePicURL defaultPic:@"illegal_icon" errorPic:nil]subscribeNext:^(UIImage *img) {

            
            logoView.image = img;
            
        }];
        
        UILabel *nameLabel = [cell viewWithTag:101];
        nameLabel.text = self.serviceName.length == 0 ? @"违章代办" : self.serviceName;
        
    });
    
    return data;
}

- (CKDict *)shopItemCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"ShopItemCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 25;
    });
    
    return data;
}

- (CKDict *)itemFeeCellDataWithItem:(NSString *)itemTitle
{
    @weakify(self)
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"ItemFeeCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 25;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        UILabel *itemLabel = [cell viewWithTag:100];
        itemLabel.text = itemTitle;
        
        
        UILabel *feeLabel = [cell viewWithTag:101];
        if ([itemTitle isEqualToString:@"违章罚款"])
        {
            feeLabel.text = [NSString stringWithFormat:@"¥%.2f",self.money.doubleValue];
        }
        else if ([itemTitle isEqualToString:@"手续费"])
        {
            feeLabel.text = [NSString stringWithFormat:@"¥%.2f",self.serviceFee.doubleValue];
        }
        else
        {
            feeLabel.text = [NSString stringWithFormat:@"¥%.2f",self.totalFee.doubleValue];
        }
        
    });
    
    return data;
}

- (CKDict *)couponCellData
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"CouponInfoCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        UILabel *label = [cell viewWithTag:1001];
        UILabel *detailLabel = [cell viewWithTag:1002];
        UILabel *dateLabel = [cell viewWithTag:1003];
        
        label.text = @"违章代办优惠券";
        
        if (self.selectCoupouArray.count > 0)
        {
            dateLabel.text = [self calcCouponValidDateString:self.selectCoupouArray];
            HKCoupon *coupon = [self.selectCoupouArray safetyObjectAtIndex:0];
            detailLabel.text = coupon.couponName;
        }
        else
        {
            dateLabel.text = nil;
            detailLabel.text = nil;
        }
        [self refreshBottomView];
        
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        ChooseCouponVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"ChooseCouponVC"];
        vc.originVC = self;
        vc.numberLimit = 1;
        vc.type = CouponTypeGasNormal; /// 加油券类型的用普通代替
        vc.selectedCouponArray = self.selectCoupouArray;
        vc.couponArray = self.couponArray;
        [self.navigationController pushViewController:vc animated:YES];
        
    });
    
    return data;
    
}

- (CKDict *)otherCellData
{
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"OtherInfoCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 42;
    });
    
    return data;
    
}

#pragma mark - Action

- (IBAction)actionPay:(id)sender
{
    [self payViolationCommissionOrder];
}

#pragma mark - Utility

- (NSString *)calcCouponValidDateString:(NSArray *)couponArray
{
    NSDate * earlierDate;
    NSDate * laterDate;
    for (HKCoupon * c in couponArray)
    {
        earlierDate = [c.validsince earlierDate:earlierDate];
        laterDate = [c.validthrough laterDate:laterDate];
    }
    NSString * string = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
    
    return string;
}

- (void)paySuccess
{
    
    @weakify(self)
    
    // 发送支付成功通知
    
    [self postCustomNotificationName:kNotifyViolationPaySuccess object:nil];
    
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:HEXCOLOR(@"#18D06A") clickBlock:^(id alertVC) {
        
        @strongify(self)
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_ok" Message:@"订单支付成功。请点进确认返回" ActionItems:@[confirm]];
    
    [alert show];
    
}

- (void)refreshBottomView
{
    HKCoupon *coupon = self.selectCoupouArray.firstObject;
    CGFloat totalFee = self.totalFee.doubleValue - coupon.couponAmount;
    
    NSString *title = nil;
    
    if (coupon.couponAmount > 0)
    {
        title = [NSString stringWithFormat:@"已优惠%.2f元，您只需支付%.2f元，现在支付", coupon.couponAmount,totalFee];
    }
    else
    {
        title = [NSString stringWithFormat:@"您需支付%.2f元，现在支付",self.totalFee.doubleValue];
    }
    
    [self.button setTitle:title forState:UIControlStateNormal];
    
}

#pragma mark - LazyLoad

- (CKList *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [CKList list];
    }
    return _dataSource;
}


@end
