//
//  ViolationPayConfirmVC.m
//  XMDD
//
//  Created by RockyYe on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ViolationPayConfirmVC.h"
#import "ChooseCouponVC.h"
#import "GetViolationCommissionCouponsOp.h"
#import "ConfirmViolationCommissionOrderConfirmOp.h"

@interface ViolationPayConfirmVC ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (assign, nonatomic) BOOL isLoadingResourse;

@property (strong, nonatomic) NSNumber *money;
@property (strong, nonatomic) NSNumber *serviceFee;
@property (strong, nonatomic) NSNumber *totalFee;
@property (strong, nonatomic) NSArray *coupons;
@property (strong, nonatomic) NSString *serviceName;
@property (strong, nonatomic) NSString *servicePicURL;

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

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"ViolationPayConfirmVC dealloc");
}


#pragma mark - Setup

-(void)setupDataSource
{
    
    self.paychannel = PaymentChannelUPpay;
    
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
                          [self discountInfoCellData],
                          [self couponCellData]
                          ),
                        $(
                          [self otherCellData],
                          [self payPlatformCellADataWithPayChannelData:@{@"logo" : @"uppay_logo_66",
                                                                         @"name" : @"银联在线支付",
                                                                         @"isRecommend" : @(YES),
                                                                         @"type" : @(PaymentChannelUPpay)}],
                          [self applePayPlatformCellData],
                          [self payPlatformCellADataWithPayChannelData:@{@"logo" : @"alipay_logo_66",
                                                                         @"name" : @"支付宝支付",
                                                                         @"isRecommend" : @(NO),
                                                                         @"type" : @(PaymentChannelAlipay)}],
                          [self payPlatformCellADataWithPayChannelData:@{@"logo" : @"wechat_logo_66",
                                                                         @"name" : @"微信支付",
                                                                         @"isRecommend" : @(NO),
                                                                         @"type" : @(PaymentChannelWechat)}]
                          )
                        );
}

-(void)setupUI
{
    self.button.layer.cornerRadius = 5;
    self.button.layer.masksToBounds = YES;
}

#pragma mark - Network


-(void)getViolationCommissionCoupons
{
    
    @weakify(self)
    
    GetViolationCommissionCouponsOp *op = [GetViolationCommissionCouponsOp operation];
    
    [[[op rac_postRequest]initially:^{
        
        @strongify(self)
        
        self.isLoadingResourse = NO;
        
    }]subscribeNext:^(GetViolationCommissionCouponsOp *op) {
        
        @strongify(self)
        
        self.isLoadingResourse = YES;
        self.coupons = op.rsp_coupons;
        
    } error:^(NSError *error) {
        
        @strongify(self)
        self.isLoadingResourse = NO;
        
    }];
    
}

-(void)confirmViolationCommissionOrderConfirm
{
    @weakify(self)
    
    ConfirmViolationCommissionOrderConfirmOp *op = [ConfirmViolationCommissionOrderConfirmOp operation];
    
    op.req_recordid = self.recordID;
    
    [[[op rac_postRequest]initially:^{
    
        @strongify(self)
        
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        self.tableView.hidden = YES;
        
    }]subscribeNext:^(ConfirmViolationCommissionOrderConfirmOp *op) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
        
        self.money = op.rsp_money;
        self.serviceFee = op.rsp_servicefee;
        self.totalFee = op.rsp_totalfee;
        
        [self.tableView reloadData];
        
        
    } error:^(NSError *error) {
        
        @strongify(self)
        
        [self.view stopActivityAnimation];
        
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"支付信息请求失败。点击重试" tapBlock:^{
        
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - Cell

-(CKDict *)applePayPlatformCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"ApplePayPlatformCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        
        UIImageView *selectView = [cell viewWithTag:104];
        selectView.hidden = !(self.paychannel == PaymentChannelApplePay);
        
        
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        self.paychannel = PaymentChannelApplePay;
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        
    });
    
    return data;
}

-(CKDict *)payPlatformCellBData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"PayPlatformCellB"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    return data;
}

-(CKDict *)payPlatformCellADataWithPayChannelData:(NSDictionary *)payChannelData
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"PayPlatformCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIImageView *channelLogo = [cell viewWithTag:101];
        channelLogo.image = [UIImage imageNamed:payChannelData[@"logo"]];
        
        UILabel *channelName = [cell viewWithTag:102];
        channelName.text = [NSString stringWithFormat:@"%@",payChannelData[@"name"]];
        
        UIImageView *selectView = [cell viewWithTag:103];
        selectView.hidden = !([(NSNumber *)payChannelData[@"type"] integerValue] == self.paychannel);
        
        UIImageView *recommendView = [cell viewWithTag:104];
        recommendView.hidden = ![(NSNumber *)payChannelData[@"isRecommend"] boolValue];
        
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        
        self.paychannel = [(NSNumber *)payChannelData[@"type"] integerValue];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        
    });
    
    return data;
}

-(CKDict *)blankCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"BlankCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 12;
    });
    
    return data;
}

-(CKDict *)titleCellData
{
    
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"ShopTitleCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 68;
    });
    
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIImageView *logoView = [cell viewWithTag:100];
        [[gMediaMgr rac_getGifImageDataByUrl:self.servicePicURL defaultPic:@"illegal_icon" errorPic:nil]subscribeNext:^(UIImage *img) {
            
            logoView.image = img;
            
        }];
        
        UILabel *nameLabel = [cell viewWithTag:101];
        nameLabel.text = self.serviceName.length == 0 ? @"违章代办" : self.serviceName;
        
    });
    
    return data;
}

-(CKDict *)shopItemCellData
{
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"ShopItemCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 25;
    });
    
    return data;
}


-(CKDict *)itemFeeCellDataWithItem:(NSString *)itemTitle
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

-(CKDict *)discountInfoCellData
{
    
    @weakify(self)
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"DiscountInfoCell"}];
    
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
    
//    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
//        
//        //        @strongify(self)
//        
//        //        ChooseCouponVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"ChooseCouponVC"];
//        //        vc.originVC = self.originVC;
//        //        vc.type = CouponTypeCarWash;
//        //        vc.selectedCouponArray = self.selectCarwashCoupouArray;
//        //        vc.couponArray = self.getUserResourcesV2Op.validCarwashCouponArray;
//        //        [self.navigationController pushViewController:vc animated:YES];
//        
//    });
    
    return data;
}

-(CKDict *)couponCellData
{
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"CouponCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        ChooseCouponVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"ChooseCouponVC"];
        vc.originVC = self;
        vc.numberLimit = 1;
//        vc.type = CouponTypeGasNormal; /// 加油券类型的用普通代替
//        vc.selectedCouponArray = self.selectGasCoupouArray;
//        vc.couponArray = self.gasCouponArray;
//        vc.payAmount = self.gasNormalVC.rechargeAmount;
        [self.navigationController pushViewController:vc animated:YES];
        
    });
    
    return data;
    
}

-(CKDict *)otherCellData
{
    
    CKDict *data = [CKDict dictWith:@{kCKCellID : @"OtherInfoCell"}];
    
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 42;
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
    });
    
    return data;
    
}

#pragma mark - Utility

#pragma mark - LazyLoad

-(CKList *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [CKList list];
    }
    return _dataSource;
}


@end
