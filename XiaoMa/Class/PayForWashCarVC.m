//
//  PayForWashCarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PayForWashCarVC.h"
#import "XiaoMa.h"
#import "UIView+Layer.h"
#import "PaymentSuccessVC.h"
#import "ChooseCarwashTicketVC.h"
#import "GetUserResourcesOp.h"
#import "GetUserCarOp.h"
#import "HKCoupon.h"
#import "HKMyCar.h"
#import "AlipayHelper.h"
#import "WeChatHelper.h"
#import "CheckoutServiceOrderOp.h"
#import "NSDate+DateForText.h"
#import "UIView+Layer.h"
#import "MyCarsModel.h"

#define CheckBoxCouponGroup @"CheckBoxCouponGroup"
#define CheckBoxCashGroup @"CheckBoxCashGroup"


@interface PayForWashCarVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CKSegmentHelper *checkBoxHelper;

@property (nonatomic)BOOL isLoadingResourse;

@property (nonatomic)PaymentChannelType paymentType;
@property (nonatomic)PaymentPlatform platform;

@property (nonatomic,strong)NSDictionary * tbStructure;

@end

@implementation PayForWashCarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCheckBoxHelper];
    [self setupBottomView];
    
    self.paymentType = PaymentChannelAlipay;
    self.platform = PayWithAlipay;
    [self requestGetUserCar];

    self.isLoadingResourse = YES;
    [self requestGetUserResource];
    
    self.selectCarwashCoupouArray = [NSMutableArray array];
    self.selectCashCoupouArray = [NSMutableArray array];
    
    [self selectDefaultCoupon];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    DebugLog(@"PayForWashCarVC dealloc");
}

- (void)setupCheckBoxHelper
{
    self.checkBoxHelper = [CKSegmentHelper new];
}

- (void)setupBottomView
{
    //line
    [self.bottomView setBorderColor:kDefLineColor];
    [self.bottomView showBorderLineWithDirectionMask:CKViewBorderDirectionTop];
    [self.bottomView layoutBorderLineIfNeeded];
    
    //label
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:1001];
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:@"总计："
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr1];
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%.2f", self.service.origprice]
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr2];
    label.attributedText = str;
}

#pragma mark - Action
- (IBAction)actionPay:(id)sender
{
    [self requestCheckout];
}






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    if (indexPath.section == 0 && indexPath.row == 0) {
        height = 84;
    }
    if (indexPath.section != 0)
    {
        if (indexPath.row == 0)
        {
            height = 35;
        }
        else if (indexPath.row == 1 || indexPath.row == 2)
        {
            height = 55;
        }
        else
        {
            height = 44;
        }
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  CGFLOAT_MIN;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger count = 0;
    if (section == 0) {
        count = 4;
    }
    else if (section == 1) {
        count = 3;
    }
    else if (section == 2) {
        count = 3 - (gPhoneHelper.exsitWechat ? 0:1);
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [self shopTitleCellAtIndexPath:indexPath];
        }
        else {
            cell = [self shopItemCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0)
        {
            cell = [self DiscountInfoCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self paymentTypeCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0)
        {
            cell = [self OtherInfoCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self paymentModeCellAtIndexPath:indexPath];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    
    if ((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 0))
    {
        [cell.contentView setBorderLineInsets:UIEdgeInsetsMake(-1, 0, 0, 0) forDirectionMask:CKViewBorderDirectionBottom];
        [cell.contentView showBorderLineWithDirectionMask:CKViewBorderDirectionBottom];
        [cell.contentView setBorderLineColor:HEXCOLOR(@"#e0e0e0") forDirectionMask:CKViewBorderDirectionBottom];
    }
    else
    {
        jtcell.customSeparatorInset = UIEdgeInsetsMake(-1, 8, 0, 8);
        [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 1)
        {
        //点击查看洗车券
            ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
            vc.originVC = self.originVC;
            vc.type = CouponTypeCarWash;
            vc.selectedCouponArray = self.selectCarwashCoupouArray;
            vc.couponArray = gAppMgr.myUser.validCarwashCouponArray;
            vc.upperLimit = self.service.origprice;
            [self.navigationController pushViewController:vc animated:YES];
            
//            self.paymentType = PaymentChannelCoupon;
        }
        else if (indexPath.row == 2)
        {
            ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
            vc.originVC = self.originVC;
            vc.type = CouponTypeCash;
            vc.selectedCouponArray = self.selectCashCoupouArray;
            vc.couponArray = gAppMgr.myUser.validCashCouponArray;
            vc.upperLimit = self.service.origprice;
            [self.navigationController pushViewController:vc animated:YES];
        }
//        else if (indexPath.row == 2)
//        {
//            self.paymentType = PaymentChannelABCCarWashAmount;
//        }
//        else if (indexPath.row == 3)
//        {
//            self.paymentType = PaymentChannelABCIntegral;
//        }
        
        ///取消支付宝，微信勾选
        [self.tableView reloadData];
    }
}

#pragma mark - TableViewCell
- (UITableViewCell *)shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopTitleCell"];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1003];
    
    RAC(logoV, image) = [gMediaMgr rac_getPictureForUrl:[self.shop.picArray safetyObjectAtIndex:0]
                                               withType:ImageURLTypeThumbnail defaultPic:@"cm_shop" errorPic:@"cm_shop"];
    titleL.text = self.shop.shopName;
    addrL.text = self.shop.shopAddress;
    
    return cell;
}

- (UITableViewCell *)shopItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopItemCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UIButton *additionB = (UIButton *)[cell.contentView viewWithTag:1002];
    
    if (indexPath.row == 1) {
        titleL.text = [NSString stringWithFormat:@"服务项目：%@", self.service.serviceName];
        additionB.hidden = YES;
    }
    else if (indexPath.row == 2) {
        titleL.text = [NSString stringWithFormat:@"项目价格：￥%.2f", self.service.origprice];
        NSArray * rates = self.service.chargeArray;
        ChargeContent * cc;
        for (ChargeContent * tcc in rates)
        {
            if (cc.paymentChannelType == PaymentChannelABCIntegral)
            {
                cc = tcc;
                break;
            }
        }
        additionB.hidden = !cc;
        [additionB setTitle:[NSString stringWithFormat:@" %.0f分", cc.amount]forState:UIControlStateNormal];
    }
    else if (indexPath.row == 3) {
        additionB.hidden = YES;
        [[RACObserve(self, defaultCar) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(HKMyCar *car) {
            titleL.text = [NSString stringWithFormat:@"我的车辆：%@", car.licencenumber ? car.licencenumber : @""];
        }];

    }

    return cell;
}

- (UITableViewCell *)paymentTypeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentTypeCell"];

    UIButton *boxB = (UIButton *)[cell.contentView viewWithTag:1001];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *arrow = (UIImageView *)[cell.contentView viewWithTag:1003];
    UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *statusLb = (UILabel *)[cell.contentView viewWithTag:1005];
    
    if (indexPath.row == 1) {
        label.text = [NSString stringWithFormat:@"洗车券：%ld张", (long)gAppMgr.myUser.validCarwashCouponArray.count];
        arrow.hidden = NO;
        
        NSDate * earlierDate;
        NSDate * laterDate;
        for (HKCoupon * c in gAppMgr.myUser.validCarwashCouponArray)
        {
            earlierDate = [c.validsince earlierDate:earlierDate];
            laterDate = [c.validthrough laterDate:laterDate];
        }
        dateLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
        
        if (self.paymentType == PaymentChannelCoupon)
        {
            if (self.couponType == CouponTypeCarWash)
            {
                statusLb.text = @"已选中";
                statusLb.textColor = HEXCOLOR(@"#fb4209");
                statusLb.hidden = NO;
            }
            else
            {
                statusLb.text = @"未使用";
                statusLb.textColor = HEXCOLOR(@"#aaaaaa");
                statusLb.hidden = YES;
            }
        }
        else
        {
            statusLb.text = @"未使用";
            statusLb.textColor = HEXCOLOR(@"#aaaaaa");
            statusLb.hidden = YES;
        }
    }
    else if (indexPath.row == 2) {
        label.text = [NSString stringWithFormat:@"代金券：%ld张", (long)gAppMgr.myUser.validCashCouponArray.count];
        arrow.hidden = NO;
        
        NSDate * earlierDate;
        NSDate * laterDate;
        for (HKCoupon * c in gAppMgr.myUser.validCashCouponArray)
        {
            earlierDate = [c.validsince earlierDate:earlierDate];
            laterDate = [c.validthrough laterDate:laterDate];
        }
        dateLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
        
        if (self.couponType == CouponTypeCash)
        {
            statusLb.text = @"已选中";
            statusLb.textColor = HEXCOLOR(@"#fb4209");
            statusLb.hidden = NO;
        }
        else
        {
            statusLb.text = @"未使用";
            statusLb.textColor = HEXCOLOR(@"#aaaaaa");
            statusLb.hidden = YES;
        }
    }
    
    if (indexPath.row == 1 )
    {
        if (self.couponType == CouponTypeCarWash)
        {
            [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
        }
    }
    if (indexPath.row == 2)
    {
        if (self.couponType == CouponTypeCash)
        {
            [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
        }
    }

    
    // checkBox 点击处理
    @weakify(self);
    [self.checkBoxHelper addItem:boxB forGroupName:CheckBoxCouponGroup withChangedBlock:^(id item, BOOL selected) {
        
        @strongify(self);
        boxB.selected = selected;
        if ((self.couponType == CouponTypeCarWash && indexPath.row == 1) ||
            (self.couponType == CouponTypeCash && indexPath.row == 2))
        {
            statusLb.text = @"已选中";
            statusLb.textColor = HEXCOLOR(@"#fb4209");
            statusLb.hidden = NO;
        }
        else
        {
            statusLb.text = @"未使用";
            statusLb.textColor = HEXCOLOR(@"#aaaaaa");
            statusLb.hidden = YES;
        }
    }];
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        NSLog(@"click checkbox");
        @strongify(self);
        if (indexPath.row == 1)
        {
            if (!self.selectCarwashCoupouArray.count)
            {
                ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
                vc.originVC = self.originVC;
                vc.selectedCouponArray = self.selectCarwashCoupouArray;
                vc.type = CouponTypeCarWash;
                vc.couponArray = gAppMgr.myUser.validCarwashCouponArray;
                vc.upperLimit = self.service.origprice;
                [self.navigationController pushViewController:vc animated:YES];
                 [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
            }
            else
            {
                if (self.couponType == CouponTypeCarWash)
                {
                    self.couponType = 0;
                    [self.checkBoxHelper selectItem:nil forGroupName:CheckBoxCouponGroup];
                }
                else
                {
                    self.couponType = CouponTypeCarWash;
                    [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
                }
            }
            
        }
        else if (indexPath.row == 2)
        {
            if (!self.selectCashCoupouArray.count)
            {
                ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
                vc.originVC = self.originVC;
                vc.selectedCouponArray = self.selectCashCoupouArray;
                vc.type = CouponTypeCash;
                vc.couponArray = gAppMgr.myUser.validCashCouponArray;
                vc.upperLimit = self.service.origprice;
                [self.navigationController pushViewController:vc animated:YES];
                [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
            }
            else
            {
                if (self.couponType == CouponTypeCash)
                {
                    self.couponType = 0;
                     [self.checkBoxHelper selectItem:nil forGroupName:CheckBoxCouponGroup];
                }
                else
                {
                    self.couponType = CouponTypeCash;
                    [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
                }
                
            }
        }
        
        [self refreshPriceLb];
    }];

    return cell;
}

- (UITableViewCell *)paymentModeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentModeCell"];
    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UIButton *boxB = (UIButton *)[cell.contentView viewWithTag:1003];
    if (indexPath.row == 1) {
        iconV.image = [UIImage imageNamed:@"cw_alipay"];
        titleL.text = @"支付宝支付";
    }
    else if (indexPath.row == 2) {
        iconV.image = [UIImage imageNamed:@"cw_wechat"];
        titleL.text = @"微信支付";
    }
    @weakify(self);
    [self.checkBoxHelper addItem:boxB forGroupName:CheckBoxCashGroup withChangedBlock:^(id item, BOOL selected) {
        boxB.selected = selected;
    }];

    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        
//        if (self.paymentType == PaymentChannelABCCarWashAmount ||
//            self.paymentType == PaymentChannelABCIntegral ||
//            self.paymentType == PaymentChannelCoupon)
//        {
//            [self.tableView reloadData];
//        }
        
        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCashGroup];
        
        if (self.couponType == 0)
        {
            if (indexPath.row == 1)
            {
                self.paymentType = PaymentChannelAlipay;
            }
            else
            {
                self.paymentType = PaymentChannelWechat;
            }
        }
    }];
    
    if (indexPath.row == 1 && self.paymentType == PaymentChannelAlipay)
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCashGroup];
    }
    if (indexPath.row == 2 && self.paymentType == PaymentChannelWechat)
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCashGroup];
    }
    
    return cell;
}

- (UITableViewCell *)DiscountInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DiscountInfoCell"];
    UIActivityIndicatorView * indicator = (UIActivityIndicatorView *)[cell searchViewWithTag:202];
    indicator.animating = self.isLoadingResourse;
    indicator.hidden = !self.isLoadingResourse;
    return cell;
}

- (UITableViewCell *)OtherInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OtherInfoCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Utility
- (void)requestGetUserResource
{
    GetUserResourcesOp * op = [GetUserResourcesOp operation];
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetUserResourcesOp * op) {
        
        gAppMgr.myUser.abcCarwashesCount = op.rsp_freewashes;
        gAppMgr.myUser.abcIntegral = op.rsp_bankIntegral;
        NSArray * carwashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
           
            if (c.conponType == CouponTypeCarWash)
            {
                if (c.valid)
                {
                        return YES;
                }
            }
            return NO;
        }];
        gAppMgr.myUser.validCarwashCouponArray = [carwashfilterArray sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(HKCoupon  * obj1, HKCoupon  * obj2) {
            
            return obj1.validthrough == [obj1.validthrough laterDate:obj2.validthrough];
        }];
        
        NSArray * cashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
            
            if (c.conponType == CouponTypeCash)
            {
                if (c.valid)
                {
                    return YES;
                }
            }
            return NO;
        }];
        gAppMgr.myUser.validCashCouponArray = [cashfilterArray sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(HKCoupon  * obj1, HKCoupon  * obj2) {
            
            return obj1.couponAmount > obj2.couponAmount;
        }];
        
        self.isLoadingResourse = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        
        [self selectDefaultCoupon];
    } error:^(NSError *error) {
        
        self.isLoadingResourse = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)requestGetUserCar
{
    [[gAppMgr.myUser.carModel rac_getDefaultCar] subscribeNext:^(id x) {
        self.defaultCar = x;
    }];
}

- (void)requestCheckout
{
    CheckoutServiceOrderOp * op = [CheckoutServiceOrderOp operation];
    op.serviceid = self.service.serviceID;
    op.licencenumber = self.defaultCar.licencenumber ? self.defaultCar.licencenumber : @"";
    if (self.couponType > 0)
    {
        if (self.couponType == CouponTypeCarWash)
        {
            NSMutableArray * array = [NSMutableArray array];
            for (HKCoupon * c in self.selectCarwashCoupouArray)
            {
                [array addObject:c.couponId];
            }
            op.couponArray = array;
        }
        else if (self.couponType == CouponTypeCash)
        {
            NSMutableArray * array = [NSMutableArray array];
            for (HKCoupon * c in self.selectCashCoupouArray)
            {
                [array addObject:c.couponId];
            }
            op.couponArray = array;
        }
        op.paychannel = PaymentChannelCoupon;
    }
 
    NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxCashGroup];
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        BOOL s = btn.selected;
        if (s == YES)
        {
            if (i == 0)
            {
                
                if (self.couponType > 0)
                {
                    op.platform = PayWithAlipay;
                }
                else
                {
                    op.platform = PayWithAlipay;
                    op.paychannel = PaymentChannelAlipay;
                }
            }
            else if (i == 1)
            {
                if (self.couponType > 0)
                {
                    op.platform = PayWithWechat;
                }
                else
                {
                    op.platform = PayWithWechat;
                    op.paychannel = PaymentChannelWechat;
                }
            }
        }
        
    }
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"订单生成中..."];
    }] subscribeNext:^(CheckoutServiceOrderOp * op) {
        
        if (op.rsp_code == 0)
        {
            if (op.rsp_price)
            {
                if (op.platform == PayWithAlipay)
                {
                    [gToast showText:@"订单生成成功,正在跳转到支付宝平台进行支付"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        NSString * submitTime = [[NSDate date] dateFormatForDT8];
                        NSString * info = [NSString stringWithFormat:@"%@",self.shop.shopName];
                        [self requestAliPay:op.rsp_orderid andTradeId:op.rsp_tradeId andPrice:op.rsp_price
                             andProductName:info andDescription:@"小马达达" andTime:submitTime];
                    });
                }
                else if (op.platform == PayWithWechat)
                {
                    [gToast showText:@"订单生成成功,正在跳转到微信平台进行支付"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        NSString * submitTime = [[NSDate date] dateFormatForDT8];
                        NSString * info = [NSString stringWithFormat:@"%@-%@",self.service.serviceName,self.shop.shopName];
                        [self requestWechatPay:op.rsp_orderid andTradeId:op.rsp_tradeId andPrice:op.rsp_price
                                andProductName:info andTime:submitTime];
                    });
                }
            }
            else
            {
                [gToast dismiss];
                [self postCustomNotificationName:kNotifyRefreshMyCarwashOrders object:nil];
                PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
                vc.originVC = self.originVC;
                HKServiceOrder * order = [[HKServiceOrder alloc] init];
                order.orderid = op.rsp_orderid;
                order.shop = self.shop;
                order.serviceid = self.service.serviceID;
                vc.order = order;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else
        {
            [gToast showError:@"订单生成失败"];
        }
    } error:^(NSError *error) {
        
        [gToast showError:@"订单生成失败"];
    }];
}

- (void)requestAliPay:(NSNumber *)orderId andTradeId:(NSString *)tradeId
             andPrice:(CGFloat)price andProductName:(NSString *)name andDescription:(NSString *)desc andTime:(NSString *)time
{
    [gAlipayHelper payOrdWithTradeNo:tradeId andProductName:name andProductDescription:desc andPrice:price];
    
    [gAlipayHelper.rac_alipayResultSignal subscribeNext:^(id x) {
        
        [self postCustomNotificationName:kNotifyRefreshMyCarwashOrders object:nil];
        PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
        vc.originVC = self.originVC;
        vc.subtitle = [NSString stringWithFormat:@"我完成了%0.2f元洗车，赶快去告诉好友吧！",price];
        HKServiceOrder * order = [[HKServiceOrder alloc] init];
        order.orderid = orderId;
        order.serviceid = self.service.serviceID;
        order.shop = self.shop;
        vc.order = order;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
    }];
}

- (void)requestWechatPay:(NSNumber *)orderId andTradeId:(NSString *)tradeId
                andPrice:(CGFloat)price andProductName:(NSString *)name
                 andTime:(NSString *)time
{
    [gWechatHelper payOrdWithTradeNo:tradeId andProductName:name andPrice:price];
    
    [gWechatHelper.rac_wechatResultSignal subscribeNext:^(id x) {
        
        [self postCustomNotificationName:kNotifyRefreshMyCarwashOrders object:nil];
        PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
        vc.originVC = self.originVC;
        vc.subtitle = [NSString stringWithFormat:@"我完成了%0.2f元洗车，赶快去告诉好友吧！",price];
        HKServiceOrder * order = [[HKServiceOrder alloc] init];
        order.orderid = orderId;
        order.serviceid = self.service.serviceID;
        order.shop = self.shop;
        vc.order = order;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
    }];
}

- (void)selectDefaultCoupon
{
    [self.selectCarwashCoupouArray removeAllObjects];
    [self.selectCashCoupouArray removeAllObjects];
    if (gAppMgr.myUser.validCarwashCouponArray.count)
    {
        self.couponType = CouponTypeCarWash;
        [self.selectCarwashCoupouArray addObject:[gAppMgr.myUser.validCarwashCouponArray safetyObjectAtIndex:0]];
        [self tableViewReloadData];
        return;
    }
    if (gAppMgr.myUser.validCashCouponArray.count)
    {
        NSInteger amount = 0;
        for (NSInteger i = 0 ; i < gAppMgr.myUser.validCashCouponArray.count ; i++)
        {
            HKCoupon * coupon = [gAppMgr.myUser.validCashCouponArray safetyObjectAtIndex:i];
            if (coupon.couponAmount < self.service.origprice)
            {
                if (amount + coupon.couponAmount < self.service.origprice)
                {
                    amount = amount + coupon.couponAmount;
                    [self.selectCashCoupouArray addObject:coupon];
                    self.couponType = CouponTypeCash;
                }
            }
        }
        [self tableViewReloadData];
    }
}

- (void)refreshPriceLb
{
    CGFloat amount = self.service.origprice;
    if (self.couponType == CouponTypeCarWash)
    {
        HKCoupon * coupon = [self.selectCarwashCoupouArray safetyObjectAtIndex:0];
        amount = coupon.couponAmount;
    }
    else if (self.couponType == CouponTypeCash)
    {
        for (NSInteger i = 0 ; i < self.selectCashCoupouArray.count ; i++)
        {
            HKCoupon * coupon = [self.selectCashCoupouArray safetyObjectAtIndex:i];
            amount = amount - coupon.couponAmount;
        }
    }
    else
    {
        amount = self.service.origprice;
    }
    
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:1001];
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:@"总计："
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr1];
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%.2f", amount]
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr2];
    label.attributedText = str;
    
}

- (void)setSelectCarwashCoupouArray:(NSMutableArray *)selectCarwashCoupouArray
{
    _selectCarwashCoupouArray = selectCarwashCoupouArray;
}

- (void)setSelectCashCoupouArray:(NSMutableArray *)selectCashCoupouArray
{
    _selectCashCoupouArray = selectCashCoupouArray;
}

- (void)setPaymentType:(PaymentChannelType)paymentType
{
    _paymentType = paymentType;
}

- (void)setCouponType:(CouponType)couponType
{
    _couponType = couponType;
}

- (void)tableViewReloadData
{
    [self.checkBoxHelper selectItem:nil forGroupName:CheckBoxCouponGroup];
    [self.tableView reloadData];
    [self refreshPriceLb];
}

@end
