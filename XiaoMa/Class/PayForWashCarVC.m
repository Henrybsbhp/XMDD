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





@interface PayForWashCarVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CKSegmentHelper *checkBoxHelper;

@property (nonatomic)BOOL isLoadingResourse;

/// 是否添加车辆（请求我的车辆成功，且无车辆）
@property (nonatomic)BOOL needAppendCarFlag;

@property (nonatomic)PaymentChannelType paymentType;

@property (nonatomic,strong)NSNumber * couponId;

@property (nonatomic,strong)NSDictionary * tbStructure;

@end

@implementation PayForWashCarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCheckBoxHelper];
    [self setupBottomView];
    
    self.paymentType = PaymentChannelAlipay;
    
    /// 进入此页面，要么有车辆信息，要么车辆信息获取失败（）
    if (!gAppMgr.myUser.carArray)
    {
        [self requestGetUserCar];
    }

    self.isLoadingResourse = YES;
    [self requestGetUserResource];
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
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%.2f", self.service.contractprice]
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr2];
    label.attributedText = str;
}

//- (void)reloadDatasource
//{
//    self.paymentTypeList = [gAppMgr.myUser paymentTypes];
//    [self.tableView reloadData];
//}

#pragma mark - Action
- (IBAction)actionPay:(id)sender
{
    if (self.paymentType == PaymentChannelCoupon)
    {
        if (gAppMgr.myUser.validCarwashArray.count == 0)
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前没有优惠劵，可能导致提交失败，请选择其他方式支付" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:@"继续提交", nil];
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * num) {
                
                NSInteger index = [num integerValue];
                if (index == 1)
                {
                    [self requestCheckout];
                }
            }];
            [av show];
        }
    }
    else if (self.paymentType == PaymentChannelABCCarWashAmount)
    {
        if (gAppMgr.myUser.abcCarwashesCount == 0)
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前没有免费洗车次数，可能导致提交失败，请选择其他方式支付" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:@"继续提交", nil];
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * num) {
                
                NSInteger index = [num integerValue];
                if (index == 1)
                {
                    [self requestCheckout];
                }
            }];
            [av show];
        }
    }
   else if (self.paymentType == PaymentChannelABCIntegral)
    {
        if (gAppMgr.myUser.abcIntegral < 1)/// @fq 积分不够
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您目前积分不够，可能导致提交失败，请选择其他方式支付" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:@"继续提交", nil];
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * num) {
                
                NSInteger index = [num integerValue];
                if (index == 1)
                {
                    [self requestCheckout];
                }
            }];
            [av show];
        }
    }
    else // 支付宝或微信
    {
        [self requestCheckout];
    }
    
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
        count = 2;
    }
    else if (section == 2) {
        count = 3 - (gPhoneHelper.exsitWechat ? 1:0);
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
        //点击查看优惠券
            ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
            vc.originVC = self.originVC;
            vc.couponId = self.couponId;
            vc.couponArray = gAppMgr.myUser.validCarwashArray;
            [self.navigationController pushViewController:vc animated:YES];
            
//            self.paymentType = PaymentChannelCoupon;
        }
        else if (indexPath.row == 2)
        {
            self.paymentType = PaymentChannelABCCarWashAmount;
        }
        else if (indexPath.row == 3)
        {
            self.paymentType = PaymentChannelABCIntegral;
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
    
    RAC(logoV, image) = [gMediaMgr rac_getPictureForUrl:[self.shop.picArray safetyObjectAtIndex:0]
                                         withDefaultPic:@"tmp_ad"];
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
        titleL.text = [NSString stringWithFormat:@"项目价格：￥%.2f", self.service.contractprice];
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
        
        if (self.defaultCar.licencenumber.length)
        {
            titleL.text = [NSString stringWithFormat:@"我的车辆：%@", self.defaultCar.licencenumber];
            additionB.hidden = YES;
        }
        else
        {
            titleL.text = [NSString stringWithFormat:@"我的车辆："];
            additionB.hidden = YES;
        }
    }

    return cell;
}

- (UITableViewCell *)paymentTypeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentTypeCell"];
    if (indexPath.row == 3)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentTypeCellB"];
    }
    UIButton *boxB = (UIButton *)[cell.contentView viewWithTag:1001];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *arrow = (UIImageView *)[cell.contentView viewWithTag:1003];
    UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *statusLb = (UILabel *)[cell.contentView viewWithTag:1005];
    
    if (indexPath.row == 1) {
        label.text = [NSString stringWithFormat:@"免费洗车券：%ld张", (long)gAppMgr.myUser.validCarwashArray.count];
        arrow.hidden = NO;
        dateLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",[[NSDate date] dateFormatForYYMMdd2],[[NSDate date] dateFormatForYYMMdd2]];
        
        if (self.paymentType == PaymentChannelCoupon)
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
        label.text = [NSString stringWithFormat:@"农行卡免费洗车次数：%ld次", (long)gAppMgr.myUser.abcCarwashesCount];
        dateLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",[[NSDate date] dateFormatForYYMMdd2],[[NSDate date] dateFormatForYYMMdd2]];
        
        if (self.paymentType == PaymentChannelABCCarWashAmount)
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
        label.text = [NSString stringWithFormat:@"农行卡积分：%ld分", (long)gAppMgr.myUser.abcIntegral];
        
        if (self.paymentType == PaymentChannelABCIntegral)
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
    
    if (indexPath.row == 1 && self.paymentType == PaymentChannelCoupon)
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
    }
    if (indexPath.row == 2 && self.paymentType == PaymentChannelABCCarWashAmount)
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
    }
    if (indexPath.row == 3 && self.paymentType == PaymentChannelABCIntegral)
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
    }
    
    
    // checkBox 点击处理
    @weakify(self);
    [self.checkBoxHelper addItem:boxB forGroupName:@"PaymentType" withChangedBlock:^(id item, BOOL selected) {
        boxB.selected = selected;
    }];
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        if (indexPath.row == 1)
        {
            if (gAppMgr)
            self.paymentType = PaymentChannelCoupon;
            if (!self.couponId)
            {
                ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
                vc.originVC = self.originVC;
                vc.couponId = self.couponId;
                vc.couponArray = gAppMgr.myUser.validCarwashArray;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else if (indexPath.row == 2)
        {
            self.paymentType = PaymentChannelABCCarWashAmount;
        }
        else if (indexPath.row == 3)
        {
            self.paymentType = PaymentChannelABCIntegral;
        }
        [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
        
        [self.tableView reloadData];
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
    [self.checkBoxHelper addItem:boxB forGroupName:@"PaymentType" withChangedBlock:^(id item, BOOL selected) {
        boxB.selected = selected;
    }];

    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        
        if (self.paymentType == PaymentChannelABCCarWashAmount ||
            self.paymentType == PaymentChannelABCIntegral ||
            self.paymentType == PaymentChannelCoupon)
        {
            [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
            if (indexPath.row == 1)
            {
                self.paymentType = PaymentChannelAlipay;
            }
            else
            {
                self.paymentType = PaymentChannelWechat;
            }
            
            [self.tableView reloadData];
        }
        else
        {
            [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
        }
    }];
    
    if (indexPath.row == 1 && self.paymentType == PaymentChannelAlipay)
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
    }
    if (indexPath.row == 2 && self.paymentType == PaymentChannelWechat)
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:@"PaymentType"];
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
        gAppMgr.myUser.validCarwashArray = op.rsp_coupons;
        
        self.isLoadingResourse = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    } error:^(NSError *error) {
        
        self.isLoadingResourse = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)requestGetUserCar
{
    [[gAppMgr.myUser rac_requestGetUserCar] subscribeNext:^(NSArray * array) {
        
        if (array.count)
        {
            self.defaultCar = [gAppMgr.myUser getDefaultCar];
            NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

- (void)requestCheckout
{
    CheckoutServiceOrderOp * op = [CheckoutServiceOrderOp operation];
    op.serviceid = self.service.serviceID;
    op.licencenumber = [gAppMgr.myUser getDefaultCar].licencenumber ? [gAppMgr.myUser getDefaultCar].licencenumber : @"";
    op.cid = @"";
    op.paychannel = self.paymentType;
    [[[op rac_postRequest] initially:^{
        
        [SVProgressHUD showWithStatus:@"订单生成中..."];
    }] subscribeNext:^(CheckoutServiceOrderOp * op) {
        
        if (op.rsp_code == 0)
        {
            if (op.paychannel == PaymentChannelAlipay)
            {
                [SVProgressHUD showWithStatus:@"订单生成成功,正在跳转到支付宝平台进行支付" duration:2.0f];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    NSString * submitTime = [[NSDate date] dateFormatForDT8];
                    NSString * info = [NSString stringWithFormat:@"%@",self.shop.shopName];
                    [self requestAliPay:op.rsp_orderid andPrice:op.rsp_price
                      andProductName:info andDescription:@"小马达达" andTime:submitTime];
                });
            }
            else if (op.paychannel == PaymentChannelWechat)
            {
                [SVProgressHUD showWithStatus:@"订单生成成功,正在跳转到微信平台进行支付" duration:2.0f];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    NSString * submitTime = [[NSDate date] dateFormatForDT8];
                    NSString * info = [NSString stringWithFormat:@"%@",self.shop.shopName];
                    [self requestWechatPay:op.rsp_orderid andPrice:op.rsp_price
                      andProductName:info andTime:submitTime];
                });
            }
            else
            {
                PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
                vc.originVC = self.originVC;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"订单生成失败"];
        }
    } error:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"订单生成失败"];
    }];
}

- (void)requestAliPay:(NSString *)orderId andPrice:(CGFloat)price
       andProductName:(NSString *)name andDescription:(NSString *)desc andTime:(NSString *)time
{
    [gAlipayHelper payOrdWithTradeNo:orderId andProductName:name andProductDescription:desc andPrice:price];
    
    [gAlipayHelper.rac_alipayResultSignal subscribeNext:^(id x) {
        
        PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
        vc.originVC = self.originVC;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
    }];
}

- (void)requestWechatPay:(NSString *)orderId andPrice:(CGFloat)price
          andProductName:(NSString *)name andTime:(NSString *)time
{
    [gWechatHelper payOrdWithTradeNo:orderId andProductName:name andPrice:price];
    
    [gWechatHelper.rac_wechatResultSignal subscribeNext:^(id x) {
        
        PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
        vc.originVC = self.originVC;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
    }];
}

- (void)setCouponId:(NSNumber *)couponId
{
    _couponId = couponId;
}

- (void)setPaymentType:(PaymentChannelType)paymentType
{
    _paymentType = paymentType;
}

- (void)tableViewReloadData
{
    [self.tableView reloadData];
}

@end
