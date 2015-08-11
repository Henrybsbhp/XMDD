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
#import "GetUserResourcesV2Op.h"
#import "GetUserCarOp.h"
#import "HKCoupon.h"
#import "HKMyCar.h"
#import "AlipayHelper.h"
#import "WeChatHelper.h"
#import "CheckoutServiceOrderV2Op.h"
#import "NSDate+DateForText.h"
#import "UIView+Layer.h"
#import "MyCarsModel.h"
#import <POP.h>

#define CheckBoxCouponGroup @"CheckBoxCouponGroup"
#define CheckBoxPlatformGroup @"CheckBoxPlatformGroup"


@interface PayForWashCarVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (nonatomic,strong)UIView * drawerView;

@property (nonatomic, strong) CKSegmentHelper *checkBoxHelper;

@property (nonatomic)BOOL isLoadingResourse;

///支付平台，（section == 2）
@property (nonatomic)PaymentPlatform platform;

@end

@implementation PayForWashCarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCheckBoxHelper];
    [self setupBottomView];
    
    ///一开始设置支付宝，保证可用资源获取失败的时候能够正常默认选择
    self.platform = PayWithAlipay;

    self.isLoadingResourse = YES;
    [self requestGetUserResource];
    
    self.selectCarwashCoupouArray = [NSMutableArray array];
    self.selectCashCoupouArray = [NSMutableArray array];
    
    [self selectDefaultCoupon];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp108"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp108"];
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
    [MobClick event:@"rp108-7"];
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"支付确认" message:@"请务必到店享受服务，且与店员确认服务商家与软件当前支付商家一致后再付款，付完不退款" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
        
        NSInteger index = [number integerValue];
        if (index == 1)
        {
            [self requestCheckout];
        }
    }];
    [av show];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            height = 76;
        }
        else if (indexPath.row == 3){
            height = 30;
        }
        else
        {
            height = 26;
        }
    }
    if (indexPath.section != 0){
        if (indexPath.row == 0){
            height = 30;
        }
        else{
            height = 50;
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
        count = 4 - (gPhoneHelper.exsitWechat ? 0:1);
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
            cell = [self paymentPlatformACellAtIndexPath:indexPath];
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
        if (indexPath.section == 0)
        {
            if (indexPath.row != 3)
            {
                return;
            }
        }
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
            [MobClick event:@"rp108-2"];
            ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
            vc.originVC = self.originVC;
//            HKCoupon * c = [self.selectCarwashCoupouArray safetyObjectAtIndex:0];
            vc.type = CouponTypeCarWash;
            vc.selectedCouponArray = self.selectCarwashCoupouArray;
            vc.couponArray = gAppMgr.myUser.validCarwashCouponArray;
            vc.upperLimit = self.service.origprice;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (indexPath.row == 2)
        {
            [MobClick event:@"rp108-4"];
            ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
            vc.originVC = self.originVC;
            vc.type = CouponTypeCash;
            vc.selectedCouponArray = self.selectCashCoupouArray;
            vc.couponArray = gAppMgr.myUser.validCashCouponArray;
            vc.upperLimit = self.service.origprice;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
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
    logoV.cornerRadius = 5.0f;
    logoV.layer.masksToBounds = YES;
    
    [logoV setImageByUrl:[self.shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    titleL.text = self.shop.shopName;
    addrL.text = self.shop.shopAddress;
    
    return cell;
}

- (UITableViewCell *)shopItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopItemCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *infoL = (UILabel *)[cell.contentView viewWithTag:1002];
    
    if (indexPath.row == 1) {
        titleL.text = [NSString stringWithFormat:@"服务项目"];
        infoL.textColor = HEXCOLOR(@"#505050");
        infoL.text = self.service.serviceName;
    }
    else if (indexPath.row == 2) {
        titleL.text = [NSString stringWithFormat:@"项目价格"];
        infoL.textColor = HEXCOLOR(@"#fb4209");
        infoL.text = [NSString stringWithFormat:@"￥%.2f",self.service.origprice];
    }
    else if (indexPath.row == 3) {
        [[RACObserve(self, defaultCar) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(HKMyCar *car) {
            titleL.text = [NSString stringWithFormat:@"我的车辆"];
            infoL.textColor = HEXCOLOR(@"#505050");
            infoL.text = car.licencenumber ? car.licencenumber : @"";
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
        
        if (self.couponType == CouponTypeCarWash || self.couponType == CouponTypeCZBankCarWash)
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
    
    if ((self.couponType == CouponTypeCarWash && indexPath.row == 1) ||
        (self.couponType == CouponTypeCZBankCarWash && indexPath.row == 1) ||
        (self.couponType == CouponTypeCash && indexPath.row == 2))
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
    }
    
    // checkBox 点击处理
    NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxCouponGroup];
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        if ([btn.customObject isKindOfClass:[NSIndexPath class]])
        {
            NSIndexPath * path = (NSIndexPath *)btn.customObject;
            if (path.section == indexPath.section && path.row == indexPath.row)
            {
                [self.checkBoxHelper removeItem:btn forGroupName:CheckBoxCouponGroup];
                break;
            }
        }
    }
    @weakify(self);
    boxB.customObject = indexPath;
    [self.checkBoxHelper addItem:boxB forGroupName:CheckBoxCouponGroup withChangedBlock:^(id item, BOOL selected) {
        
        @strongify(self);
        boxB.selected = selected;
        if ((self.couponType == CouponTypeCarWash && indexPath.row == 1) ||
            (self.couponType == CouponTypeCZBankCarWash && indexPath.row == 1) ||
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
        
        @strongify(self);
        if (indexPath.row == 1)
        {
            [MobClick event:@"rp108-1"];
            if (!self.selectCarwashCoupouArray.count)
            {
                ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
                vc.originVC = self.originVC;
                vc.selectedCouponArray = self.selectCarwashCoupouArray;
                vc.type = CouponTypeCarWash;//@fq
                vc.couponArray = gAppMgr.myUser.validCarwashCouponArray;
                vc.upperLimit = self.service.origprice;
                [self.navigationController pushViewController:vc animated:YES];
                 [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
            }
            else
            {
                if (self.couponType == CouponTypeCarWash || self.couponType == CouponTypeCZBankCarWash)
                {
                    self.couponType = 0;
                    [self.checkBoxHelper selectItem:nil forGroupName:CheckBoxCouponGroup];
                }
                else
                {
                    HKCoupon * c = [self.selectCarwashCoupouArray safetyObjectAtIndex:0];
                    self.couponType = c.conponType;
                    if (self.couponType == CouponTypeCZBankCarWash){
                        self.platform = PayWithXMDDCreditCard;
                    }
                    [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
                }
            }
            
        }
        else if (indexPath.row == 2)
        {
            NSLog(@"click checkbox2");
            [MobClick event:@"rp108-3"];
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

        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        [self refreshPriceLb];
    }];

    return cell;
}

- (UITableViewCell *)paymentPlatformACellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIImageView *iconV,*drawerIV;
    UILabel *titleLb,*noteLb,*numberLb;
    UIButton *boxB;
    UIView * drawerV;
    if (indexPath.row == 1)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformCellB"];
        iconV = (UIImageView *)[cell searchViewWithTag:1001];
        titleLb = (UILabel *)[cell searchViewWithTag:1002];
        noteLb = (UILabel *)[cell searchViewWithTag:1004];
        drawerV = (UIView *)[cell searchViewWithTag:104];
        boxB = (UIButton *)[cell searchViewWithTag:20401];
        drawerIV = (UIImageView *)[cell  searchViewWithTag:20402];
        numberLb = (UILabel *)[cell searchViewWithTag:20403];
        self.drawerView = drawerV;
        drawerIV.image = [[UIImage imageNamed:@"cw_ticket_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformCellA"];
        iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
        titleLb = (UILabel *)[cell.contentView viewWithTag:1002];
        noteLb = (UILabel *)[cell.contentView viewWithTag:1004];
        boxB = (UIButton *)[cell.contentView viewWithTag:1003];
    }
    
    if (indexPath.row == 1) {
        iconV.image = [UIImage imageNamed:@"cw_creditcard"];
        titleLb.text = @"信用卡支付";
        noteLb.text = @"推荐小马达达信用卡用户使用";
        if (gAppMgr.myUser.validCZBankCreditCard.count)
        {
            titleLb.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
            boxB.enabled = YES;
        }
        else
        {
            titleLb.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
            boxB.enabled = NO;
        }
    }
    else if (indexPath.row == 2) {
        iconV.image = [UIImage imageNamed:@"cw_alipay"];
        titleLb.text = @"支付宝支付";
        noteLb.text = @"推荐支付宝用户使用";
        if (self.couponType == CouponTypeCZBankCarWash)
        {
            titleLb.textColor = [UIColor lightGrayColor];
            boxB.enabled = NO;
        }
        else
        {
            titleLb.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
            boxB.enabled = YES;
        }
    }
    else if (indexPath.row == 3) {
        iconV.image = [UIImage imageNamed:@"cw_wechat"];
        titleLb.text = @"微信支付";
        noteLb.text = @"推荐微信用户使用";
        if (self.couponType == CouponTypeCZBankCarWash)
        {
            titleLb.textColor = [UIColor lightGrayColor];
            boxB.enabled = NO;
        }
        else
        {
            titleLb.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
            boxB.enabled = YES;
        }
    }
    NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxPlatformGroup];
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        if ([btn.customObject isKindOfClass:[NSIndexPath class]])
        {
            NSIndexPath * path = (NSIndexPath *)btn.customObject;
            if (path.section == indexPath.section && path.row == indexPath.row)
            {
                [self.checkBoxHelper removeItem:btn forGroupName:CheckBoxPlatformGroup];
                break;
            }
        }
    }
    @weakify(self);
    boxB.customObject = indexPath;
    [self.checkBoxHelper addItem:boxB forGroupName:CheckBoxPlatformGroup withChangedBlock:^(id item, BOOL selected) {
        boxB.selected = selected;
    }];

    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        
        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxPlatformGroup];
        if (indexPath.row == 1)
        {
            [MobClick event:@"rp108-7"];
        }
        else if (indexPath.row == 2)
        {
            [MobClick event:@"rp108-5"];
        }
        else
        {
            [MobClick event:@"rp108-6"];
        }
        
        if (indexPath.row == 1){
            self.platform = PayWithXMDDCreditCard;
            [self popBankCardNumberAnimation:YES];
        }
        else if (indexPath.row == 2){
            self.platform = PayWithAlipay;
            [self popBankCardNumberAnimation:NO];
        }
        else{
            self.platform = PayWithWechat;
            [self popBankCardNumberAnimation:NO];
        }
    }];
    
    if ((indexPath.row == 1 && self.platform == PayWithXMDDCreditCard) ||
        (indexPath.row == 2 && self.platform == PayWithAlipay)||
        (indexPath.row == 3 && self.platform == PayWithWechat))
    {
        if (indexPath.row == 1)
        {
            [self popBankCardNumberAnimation:YES];
        }
        else
        {
            [self popBankCardNumberAnimation:NO];
        }
        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxPlatformGroup];
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
    GetUserResourcesV2Op * op = [GetUserResourcesV2Op operation];
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetUserResourcesV2Op * op) {
        
        gAppMgr.myUser.abcCarwashesCount = op.rsp_freewashes;
        gAppMgr.myUser.abcIntegral = op.rsp_bankIntegral;
        gAppMgr.myUser.validCZBankCreditCard = op.rsp_czBankCreditCard;
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
        NSArray * czBankcarwashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
            
            if (c.conponType == CouponTypeCZBankCarWash)
            {
                if (c.valid)
                {
                    return YES;
                }
            }
            return NO;
        }];
        NSArray * sortedCarwashfilterArray  = [carwashfilterArray sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(HKCoupon  * obj1, HKCoupon  * obj2) {
            
            return obj1.validthrough == [obj1.validthrough laterDate:obj2.validthrough];
        }];
        NSArray * sortedCZBankcarwashfilterArray  = [czBankcarwashfilterArray sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(HKCoupon  * obj1, HKCoupon  * obj2) {
            
            return obj1.validthrough == [obj1.validthrough laterDate:obj2.validthrough];
        }];
        
        NSMutableArray * carwashArray = [NSMutableArray arrayWithArray:sortedCZBankcarwashfilterArray];
        [carwashArray addObjectsFromArray:sortedCarwashfilterArray];
        gAppMgr.myUser.validCarwashCouponArray = [NSArray arrayWithArray:carwashArray];
        
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
        
        [self selectDefaultCoupon];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    } error:^(NSError *error) {
        
        self.isLoadingResourse = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

//- (void)requestGetUserCar
//{
//    [[gAppMgr.myUser.carModel rac_getDefaultCar] subscribeNext:^(id x) {
//        self.defaultCar = x;
//    }];
//}

- (void)requestCheckoutWithCouponType:(CouponType)couponType
{
    CheckoutServiceOrderV2Op * op = [CheckoutServiceOrderV2Op operation];
    op.serviceid = self.service.serviceID;
    op.licencenumber = self.defaultCar.licencenumber ? self.defaultCar.licencenumber : @"";
    op.carbrand = [self.defaultCar carSeriesDesc];
    op.bankCardId = @(7);
    NSMutableArray *coupons;
    if (couponType == CouponTypeCZBankCarWash)
    {
        coupons = [NSMutableArray array];
        for (HKCoupon * c in self.selectCarwashCoupouArray) {
            [coupons addObject:c.couponId];
        }
        op.paychannel = PaymentChannelXMDDCreditCard;
    }
    else if (couponType == CouponTypeCarWash) {
        coupons = [NSMutableArray array];
        for (HKCoupon * c in self.selectCarwashCoupouArray) {
            [coupons addObject:c.couponId];
        }
        op.paychannel = PaymentChannelCoupon;
    }
    else if (couponType == CouponTypeCash) {
        coupons = [NSMutableArray array];
        for (HKCoupon * c in self.selectCashCoupouArray) {
            [coupons addObject:c.couponId];
        }
        op.paychannel = PaymentChannelCoupon;
    }
    op.couponArray = coupons;
    
    //支付方式
    NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxPlatformGroup];
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        BOOL s = btn.selected;
        if (s == YES)
        {
            if (i == 0)
            {
                if (couponType > 0)
                {
                    op.platform = PayWithXMDDCreditCard;
                    op.paychannel = PaymentChannelXMDDCreditCard;
                }
                else
                {
                    op.platform = PayWithXMDDCreditCard;
                    op.paychannel = PaymentChannelXMDDCreditCard;
                }
            }
            else if (i == 1)
            {
                if (couponType > 0)
                {
                    op.platform = PayWithAlipay;
                    op.paychannel = PaymentChannelCoupon;
                }
                else
                {
                    op.platform = PayWithAlipay;
                    op.paychannel = PaymentChannelAlipay;
                }
            }
            else if (i == 1)
            {
                if (couponType > 0)
                {
                    op.platform = PayWithWechat;
                    op.paychannel = PaymentChannelCoupon;
                }
                else
                {
                    op.platform = PayWithWechat;
                    op.paychannel = PaymentChannelWechat;
                }
            }
        }
    }
    
    //如果不是原价支付，需要提供定位信息
    RACSignal *signal;
    if (couponType != CouponTypeNone) {
        signal = [[gMapHelper rac_getUserLocation] catch:^RACSignal *(NSError *error) {
            return [RACSignal return:nil];
        }];
    }
    else {
        signal = [RACSignal return:nil];
    }
    
    CheckoutServiceOrderV2Op *checkoutOp = op;
    [[[signal flattenMap:^RACStream *(MAUserLocation *location) {
        
        op.coordinate = location ? location.coordinate : gMapHelper.coordinate;
        return [op rac_postRequest];
    }] initially:^{
        
        [gToast showingWithText:@"订单生成中..."];
    }] subscribeNext:^(CheckoutServiceOrderV2Op * op) {
        
        if (op.rsp_price)
        {
            if (op.platform == PayWithAlipay)
            {
                [gToast showText:@"订单生成成功,正在跳转到支付宝平台进行支付"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    NSString * submitTime = [[NSDate date] dateFormatForDT8];
                    NSString * info = [NSString stringWithFormat:@"%@-%@",self.service.serviceName,self.shop.shopName];
                    [self requestAliPay:op.rsp_orderid andTradeId:op.rsp_tradeId andPrice:op.rsp_price
                         andProductName:info andDescription:info andTime:submitTime];
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
            else {
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
    } error:^(NSError *error) {
        
        [self handerOrderError:error forOp:checkoutOp];
    }];
}

- (void)requestCheckout
{
    [self requestCheckoutWithCouponType:self.couponType];
}

- (void)handerOrderError:(NSError *)error forOp:(CheckoutServiceOrderV2Op *)op
{
    if (error.code == 615801) {
        [gToast dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您不在该商户服务范围内，请刷新或者到店后洗完车后再支付或者原价支付。"
                                                       delegate:nil cancelButtonTitle:@"放弃支付" otherButtonTitles:@"原价支付", nil];
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
            //放弃支付
            if ([number integerValue] == 0) {
                [MobClick event:@"rp108-8"];
            }
            else if ([number integerValue] == 1) {
                [MobClick event:@"rp108-9"];
                [self requestCheckoutWithCouponType:CouponTypeNone ];
            }
        }];
        [alert show];
    }
    else {
        [gToast showError:error.domain];
    }
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
    
    [gWechatHelper.rac_wechatResultSignal subscribeNext:^(NSString * info) {
        
        if (![info isEqualToString:@"9000"])
            return;
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
        HKCoupon * coupon = [gAppMgr.myUser.validCarwashCouponArray safetyObjectAtIndex:0];
        if (coupon.conponType == CouponTypeCZBankCarWash){
            
            self.couponType = CouponTypeCZBankCarWash;
//            self.paymentType = PaymentChannelXMDDCreditCard;
            self.platform = PayWithXMDDCreditCard;
        }
        else{
            
            self.couponType = CouponTypeCarWash;
        }
        [self.selectCarwashCoupouArray addObject:coupon];
        
        if (gAppMgr.myUser.validCZBankCreditCard.count)
        {
            self.platform = PayWithXMDDCreditCard;
        }
        else
        {
            self.platform = PayWithAlipay;
        }
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
        return;
    }
    self.couponType = 0;
    [self tableViewReloadData];
}

- (void)refreshPriceLb
{
    CGFloat amount = self.service.origprice;
    if (self.couponType == CouponTypeCarWash || self.couponType == CouponTypeCZBankCarWash)
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
    
    NSString * btnText = [NSString stringWithFormat:@"您只需支付%.2f元，现在支付",amount];
    [self.payBtn setTitle:btnText forState:UIControlStateNormal];
}

- (void)setSelectCarwashCoupouArray:(NSMutableArray *)selectCarwashCoupouArray
{
    _selectCarwashCoupouArray = selectCarwashCoupouArray;
}

- (void)setSelectCashCoupouArray:(NSMutableArray *)selectCashCoupouArray
{
    _selectCashCoupouArray = selectCashCoupouArray;
}

- (void)setPlatform:(PaymentPlatform)platform
{
    _platform = platform;
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

- (void)popBankCardNumberAnimation:(BOOL)flag
{
    if (flag)
    {
        POPSpringAnimation * anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        
        CGFloat centerX = self.view.frame.size.width - 45;
        CGFloat centerY = 25;
        
        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerY)];
        anim.springBounciness = 16;
        anim.springSpeed = 6;
        //    anim.dynamicsTension = 100;
        anim.dynamicsMass = 2;
        [self.drawerView pop_addAnimation:anim forKey:@"center"];
    }
    else
    {
        POPSpringAnimation * anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        
        CGFloat centerX = self.view.frame.size.width + 5;
        CGFloat centerY = 25;
        
        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerY)];
        anim.springBounciness = 16;
        anim.springSpeed = 6;
        //    anim.dynamicsTension = 100;
        anim.dynamicsMass = 2;
        [self.drawerView pop_addAnimation:anim forKey:@"center"];
    }
}

@end
